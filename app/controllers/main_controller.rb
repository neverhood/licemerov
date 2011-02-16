class MainController < ApplicationController

  skip_before_filter :existent_user
  before_filter :require_user, :only => [:create, :update]

  def index
    @entries = RootEntry.where(:parent_id => nil).order('created_at DESC')
    @entry = RootEntry.new
  end

  def create
    @entry = RootEntry.new(params[:root_entry])
    @entry.user_id, @entry.login, @entry.author_sex = current_user.id, current_user.login, current_user.sex
    @entry.save
    respond_to do |format|
      format.html { redirect_to '/'}
      format.js {render :layout => false}
    end

  end

  def update

  end

end
