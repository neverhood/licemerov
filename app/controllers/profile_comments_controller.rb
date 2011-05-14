class ProfileCommentsController < ApplicationController

  skip_before_filter :existent_user
  before_filter :require_user, :only => [:create, :update, :destroy]
  before_filter :valid_comment, :only => [:destroy, :update]
  before_filter :valid_parent_id, :only => :create
  before_filter :valid_user_id, :only => :create

  def create
    @comment = ProfileComment.new(params[:profile_comment])
    @comment.author_id = current_user.id
    respond_to do |format|
      format.js { render :layout => false }
      if @comment.save
        @comment_with_user_details = ProfileComment.with_user_details.
            where(:id => @comment.id).first
        format.js { render :layout => false }
        format.html { redirect_to :back, :notice => t(:comment_created)}
      else
        render :nothing => true
      end
    end
  end

  def update
    respond_to do |format|
      if @comment.update_attributes(params[:photo_comment])
        format.json { render :json => {:message => t(:comment_updated), :html_class => :notice} }
        format.html { redirect_to :back, :notice => t(:comment_updated)}
      end
    end
  end

  def destroy
    respond_to do |format|
      if @comment.destroy
        format.json { render :json => {:message => t(:comment_deleted), :html_class => :warning} }
        format.html { redirect_to :back, :flash => {:warning => t(:comment_deleted)} }
      else
        render :nothing => true
      end
    end
  end

  private

  def valid_comment
    @comment = ProfileComment.where(:author_id => current_user.id).
        where(:id => params[:id]).first
    render guilty_response unless @comment
  end

  def valid_parent_id
    if params[:profile_comment][:parent_id]
      render guilty_response unless ProfileComment.where(:id => params[:profile_comment][:parent_id]).count > 0
    end
  end

  def valid_user_id
    if params[:profile_comment][:user_id]
      render guilty_response unless User.where(:id => params[:profile_comment][:user_id]).count > 0
    end
  end
end
