class FriendshipsController < ApplicationController

  skip_before_filter :existent_user, :except => [:show, :show_pending]
  skip_before_filter :delete_friendships, :except => [:show]
  before_filter :require_user
  before_filter :require_owner, :only => :show_pending
  before_filter :valid_friendship, :only => [:update, :destroy, :cancel]

  respond_to :js, :html

  def show # Show user friends
    if profile_owner?
      @friends = (params[:section] == 'pending') ? User.pending_friends_of(current_user) : User.friends_of(@user)
    else
      @friends = User.friends_of(@user)
    end

    render :template => (params[:section] == 'pending' && profile_owner?)?
        'friendships/show_pending' : 'friendships/show'

  end

  def create # Invite friend
    @friendship = current_user.friendships.build(:friend_id => params[:friend_id])
    if User.where(:id => params[:friend_id]).first && @friendship.save
      render :layout => false
    else
      render :nothing => true
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
    @friendship = Friendship.find params[:id]
    if @friendship
      @friendship.canceled, @friendship.approved = true, false
      @friendship.save
    end
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  private

  def valid_friendship
    @friendship = Friendship.find params[:id]
    unless @friendship && (@friendship.user_id == current_user.id || @friendship.friend_id == current_user.id)
      render :nothing => true
    end
  end

  def friend_id(friendship)
    (current_user.id == friendship.user_id)? friendship.friend_id : friendship.user_id
  end

end
