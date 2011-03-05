class UsersController < ApplicationController

  skip_before_filter :existent_user, :only => [:new, :create, :update]

  before_filter :require_user, :only => [:update, :edit]
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_owner, :only => [:edit]

  def show
  end

  def edit
  end

  def update
    if current_user.details.update_attributes(params[:user])
      redirect_to(edit_user_profile_path(current_user),
                  :notice => t(:succesfully_updated, :updated => t(:user_details)))
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
