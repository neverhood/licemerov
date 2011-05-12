class ProfileCommentsController < ApplicationController

  before_filter :require_user, :only => [:create, :update, :destroy]
  before_filter :valid_comment, :only => [:destroy, :update]

  def create
    @comment = ProfileComment.new(params[:profile_comment])
    @comment.author_id, @comment.author_sex, @comment.author_avatar_url =
        current_user.id, current_user.sex, current_user.avatar.url(:small)
    respond_to do |format|
      if @comment.save
        format.json { render :json => json_for(@comment) }
        format.html { redirect_to :back, :notice => t(:comment_created)}
      else
        format.json { render :json => json_for(@comment) }
        format.html { redirect_to :back, :alert => @comment.errors.values.map(&:first) }
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
        where(:id => params[:id])
  end

end
