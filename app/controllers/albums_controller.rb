class AlbumsController < ApplicationController

  before_filter :require_user, :only => [ :create, :update, :destroy ]
  before_filter :valid_album, :only => [ :update, :destroy ]
  before_filter :valid_title, :only => :show

  skip_before_filter :existent_user, :except => [ :index, :show ]

  layout Proc.new { |controller| controller.request.xhr?? false : 'application' }

  def index
    @albums = @user.albums
    @album = Album.new
  end

  def show

  end

  def create
    @user = current_user # used in view to craft link_to new album
    @album = current_user.albums.build( params[:album] )
    logger.debug( json_for(@album) )
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

  end

  def destroy
    #@album.destroy
    respond_to do |format|
      format.json {
        render :json => {:message => t(:album_deleted), :status => 200, :html_class => 'warning'  }
      }
      format.html { redirect_to :back, flash(:warning, t(:album_deleted)) }
    end
  end

  private

  def valid_album
    @album = current_user.albums.
        where( :id => params[:id] ).first
    render guilty_response unless @album
  end

  def valid_title
    @album = @user.albums.
        where( :title => params[:album_title] ).first
    redirect_to user_albums_path(@user) unless @album
  end


end
