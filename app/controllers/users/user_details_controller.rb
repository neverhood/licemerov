class UserDetailsController < ApplicationController

  skip_before_filter :existent_user, :only => :update
  before_filter :require_owner, :only => :edit
  before_filter :require_user

  def edit
  end

  def update
    if details.update_attributes(params[:user_details])
      redirect_to(edit_user_profile_path(current_user),
                  :notice => (t(:succesfully_updated, :updated => t(:user_details))))
    else
      render :action => :edit
    end
  end

  private


end
