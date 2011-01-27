class UsersController < ApplicationController

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
      redirect_to(@user, :notice => 'Welcome!')
    else
      render :action => :new
    end
  end

end
