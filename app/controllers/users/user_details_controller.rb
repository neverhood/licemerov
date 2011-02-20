class UserDetailsController < ApplicationController

  skip_before_filter :existent_user, :only => :update
  before_filter :require_owner, :only => :edit
  before_filter :require_user
  # is only used to update users avatar, since delegating image crop coordinate methods
  # from 'users' controller is kind of stupid.
  #

  def edit
  end

  def update
    if params[:user_details][:avatar]
      [:crop_x, :crop_y, :crop_w, :crop_h].each {|a| params[:user_details][a] = nil}
    end
    if details.update_attributes(params[:user_details])
      redirect_to(edit_avatar_path(:user_profile => current_user.login),
                  :notice => (t(:succesfully_updated, :updated => t(:avatar))))
    else
      render :action => :edit
    end
  end

  private


end
