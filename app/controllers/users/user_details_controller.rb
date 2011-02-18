class UserDetailsController < ApplicationController

  skip_before_filter :existent_user
  # is only used to update users avatar, since delegating image crop coordinate methods
  # is kind of stupid

  def update
    if current_user.details.update_attributes(params[:user_details])
      redirect_to(edit_user_profile_path(:user_profile => current_user.login, 
                                         :section => :edit_avatar), :notice => 'Success')
    else
    end
  end

end
