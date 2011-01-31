class MainController < ApplicationController

  skip_before_filter :existent_user
  before_filter :require_user, :only => [:create, :update]

  def index
    @entries = RootEntry.where(:parent_id => nil).order('created_at DESC')
    @entry = RootEntry.new
  end

  def create
    @entry = RootEntry.new(:body => params[:root_entry][:body], :user_id => current_user.id,
                           :login => current_user.login, :parent_id => params[:root_entry][:parent_id], :author_sex => current_user.sex)
    @entry.save
    respond_to do |format|
      format.js {render :layout => false}
    end

  end

  def update

  end

end
