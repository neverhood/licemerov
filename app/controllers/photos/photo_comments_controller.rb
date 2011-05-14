class PhotoCommentsController < ApplicationController

  skip_before_filter :existent_user
  before_filter :require_user, :only => [:create, :destroy, :update]
  before_filter :valid_comment, :only => [:destroy, :update]
  before_filter :valid_photo_id, :only => :create


  def create
    @comment = PhotoComment.new( params[:photo_comment] )
    @comment.user_id, @comment.photo_id =
        current_user.id, params[:photo_comment][:photo_id]
    
    respond_to do |format|
      if @comment.save
        format.json { render :json => json_for(PhotoComment.with_user_details.where(:id => @comment.id).first) }
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
    @comment = current_user.photo_comments.
        where(:id => params[:id]).first
    render guilty_response unless @comment
  end

  def valid_photo_id
    render guilty_response unless Photo.where(:id => params[:photo_comment][:photo_id]).count > 0
  end

end
