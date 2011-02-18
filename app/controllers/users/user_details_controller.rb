class UserDetailsController < ApplicationController

  skip_before_filter :existent_user
  # is only used to update users avatar, since delegating image crop coordinate methods
  # is kind of stupid

  def update
    if current_user.details.update_attributes(params[:user_details])
      render :text => current_user.details.cropping?
    else
      render :text => current_user.details.cropping?
    end
  end

end
