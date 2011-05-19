class UsersController < ApplicationController

  skip_before_filter :existent_user, :only => [:new, :create, :update]

  before_filter :require_user, :only => [:update, :edit]
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_owner, :only => [:edit]

  def show
    #@comments = ProfileComment.with_user_details.where(:user_id => @user.id).
     #   parent.order('"profile_comments".created_at DESC')
    @comments = @user.profile_comments.with_user_details.parent.
      order('"profile_comments".created_at DESC')
      .limit(10)
  end

  def edit
  end

  def update
    if params[:user][:avatar]
      [:crop_x, :crop_y, :crop_w, :crop_h].each {|a| params[:user][a] = nil}
    end
    if current_user.update_attributes(params[:user])
      redirect_to(edit_avatar_path(current_user),
                  :notice => t(:succesfully_updated, :updated => t(:avatar)))
    else
      render :action => :edit
    end
  end

  def new # registration page
    @user = User.new
  end

  def create
    @current_user = @user = User.new(params[:user])
    if @user.save
      redirect_to(home_page, :notice => t(:welcome))
    else
      render :action => :new
    end
  end

  private



end
