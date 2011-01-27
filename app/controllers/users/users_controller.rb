class UsersController < ApplicationController

  skip_before_filter :existent_user, :only => [:new, :create]

  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_owner, :only => [:edit, :update]

  def show
  end

  def edit
    @details = current_user.details
  end

  def update
  end

  def new # registration page
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to(@user.home_page, :notice => 'Welcome!')
    else
      render :action => :new
    end
  end


end
