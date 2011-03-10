class FriendshipsController < ApplicationController

  skip_before_filter :existent_user, :except => [:show, :show_pending]
  before_filter :require_user
  before_filter :require_owner, :only => :show_pending
  before_filter :valid_friendship, :only => [:update, :destroy, :cancel]
  before_filter :valid_section, :only => :show

  SECTIONS = %w(pending blacklist online)

  layout Proc.new { |controller| controller.request.xhr?? false : 'application' }

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
      respond_to do |format|
        format.js { render :json => { :message => t(:invite_sent), :html_class => :notice } }
        format.html { redirect_to :back, :notice => t(:invite_sent) }
      end
    else
      render :nothing => true # probably request submitted by mistake 
    end
  end

  def update # Confirm  friendship
    @friendship.approved, @friendship.canceled = true, false
    if @friendship.changed? && @friendship.save
      render :json => { :message => t(:friendship_approved), :html_class => :notice }
    else
      render :nothing => true
    end
  end

  def destroy # delete/cancel friendship
    @friendship.destroy
    # As this action skips 'existent user' filter, we must know the profile owners id to show 
    # an 'add to friends' link
    @user = User.where(:id => friend_id(@friendship)).first
    respond_to do |format|
      format.js # render js.erb for this action
      format.html { redirect_to :back }
    end
  end

  def cancel # cancel permanently (add to black list)
    @friendship.canceled, @friendship.approved = true, false
    if @friendship.changed? && @friendship.save
      respond_to do |format|
        format.html { redirect_to :back }
        format.js { render :json => {:message => t(:added_to_blacklist), :html_class => :warn } }
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
