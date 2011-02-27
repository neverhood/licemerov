class FriendshipsController < ApplicationController

  skip_before_filter :existent_user, :except => [:show]
  skip_before_filter :delete_friendships, :except => [:show]
  before_filter :require_user

  def show

  end

  def create # Add friend
    @friendship = current_user.friendships.build(:friend_id => params[:friend_id])
    @friendship.save
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def update # Confirm or Cancel friendship
    @friendship = current_user.friendship_with(User.find(params[:user_id]), :approved => :all)
    if @friendship
      if params[:approved].to_i == 0
        @friendship.destroy
      else
        @friendship.approved, @friendship.canceled = true, false
        @friendship.save
      end
    end
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def destroy # cancel permanently (add to black list)
    @friendship = Friendship.find params[:id]
    @friendship.marked_as_deleted = true
    @friendship.save
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def cancel_deletion
    @friendship = Friendship.find params[:id]
    @friendship.marked_as_deleted = false
    @friendship.save
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

  def cancel # cancel permanently (add to black list)

  end
end
