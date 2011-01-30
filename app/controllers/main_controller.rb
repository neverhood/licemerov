class MainController < ApplicationController

  skip_before_filter :existent_user

  def index
    @entry = RootEntry.new
  end

  def create
    @entry = RootEntry.new(:body => params[:entry][:body],
                           :user_id => current_user.id, :login => current_user.login)
    if @entry.save

    else

    end

  end

  def update

  end

end
