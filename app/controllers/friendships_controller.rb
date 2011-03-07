class FriendshipsController < ApplicationController

  skip_before_filter :existent_user, :except => [:show, :show_pending]
  before_filter :require_user
  before_filter :require_owner, :only => :show_pending
  before_filter :valid_friendship, :only => [:update, :destroy, :cancel]
  before_filter :valid_section, :only => :show

  SECTIONS = %w(pending blacklist online)

  def show # Show user friends
    unless profile_owner?
      @friends = User.friends_of(@user)
    else
      @friends = case params[:section]
                   when 'show' then User.friends_of(current_user)
                   when 'pending' then User.pending_friends_of(current_user)
                   when 'online' then friends_online
                   when 'blacklist' then User.blacklisted(current_user)
                 end
    end
    respond_to do |format|
      format.html
    end
  end

  def create # Invite friend
    @friendship = current_user.friendships.build(:friend_id => params[:friend_id])
    if @friendship.save
      render :layout => false
    else
      render guilty_response # check application_controller
    end
  end

  def update # Confirm  friendship
    @friendship.approved, @friendship.canceled = true, false
    respond_to do |format|
      @friendship.changed? && @friendship.save
      format.js { render :layout => false }
      format.html { redirect_to :back }
    end
  end

  def destroy # delete/cancel friendship
    @friendship.destroy
    @user = User.where(:id => friend_id(@friendship)).first
    respond_to do |format|
      format.js {render :layout => false}
      format.html { redirect_to :back }
    end
  end

  def cancel # cancel permanently (add to black list)
    @friendship.canceled, @friendship.approved = true, false
    if @friendship.changed? && @friendship.save
      respond_to do |format|
        format.html { redirect_to :back }
        format.js { render :nothing => true }
      end
    else
      render :nothing => true
    end
  end

  private

  def valid_friendship # Friendship exists and belongs to current_user
    @friendship = Friendship.find params[:id]
    unless @friendship && (@friendship.user_id == current_user.id || @friendship.friend_id == current_user.id)
      render guilty_response
    end
  end

  def valid_section
    params[:section] = 'show' unless SECTIONS.include?(params[:section]) 
  end

  def friend_id(friendship)
    (current_user.id == friendship.user_id)? friendship.friend_id : friendship.user_id
  end

end
