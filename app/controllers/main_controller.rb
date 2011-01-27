class MainController < ApplicationController

  skip_before_filter :existent_user

  def index

  end

end
