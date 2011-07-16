class AlbumsController < ApplicationController

  before_filter :require_user
  before_filter :valid_album, :only => [ :update, :destroy ]
  before_filter :valid_title, :only => [ :show, :edit ]

  skip_before_filter :existent_user, :except => [ :index, :show, :edit ]

  layout Proc.new { |controller| controller.request.xhr?? false : 'application' }

  def index
    @albums = @user.albums
    @album = Album.new
  end

  def show
    @photos = @album.photos.order('"photos".created_at DESC').limit(30).all
  end

  def edit

  end

  def create
    @user = current_user # used in view to craft link_to new album
    @album = current_user.albums.build( params[:album] )
    respond_to do |format|
      if @album.save
        format.json { render :json => json_for(@album), :status => 200 }
        format.html { redirect_to :back, :notice => t(:album_created)}
      else
        format.json {
          render :json => { :errors => @album.errors.values.map(&:first),
                            :html_class => 'alert' },
                 :status => :unprocessable_entity
        }
      end
    end
  end

  def update
    if @album.update_attributes(params[:album])
      redirect_to edit_user_album_path(current_user, @album.latinized_title),
                  :notice => t(:album_updated)
    else
      render :action => :edit
    end
  end

  def destroy
    @album.destroy
    redirect_to user_albums_path(current_user), :flash => {:warning => t(:album_deleted)}
  end

  private

  def valid_album
    @album = current_user.albums.
        where( :id => params[:id] ).first
    render guilty_response unless @album
  end

  def valid_title
    @album = @user.albums.
        where( :latinized_title => params[:album_title] ).first
    redirect_to user_albums_path(@user) unless @album
  end


end
