class AlbumsController < ApplicationController

  before_filter :require_owner, :only => [ :create, :update, :destroy ]
  before_filter :valid_album, :only => [ :update, :destroy ]
  before_filter :valid_title, :only => :show

  skip_before_filter :existent_user, :only => [ :index, :show ]

  def index
    @albums = current_user.albums
  end

  def show

  end

  def create
    @album = current_user.albums.build( params[:album] )
  end

  def update

  end

  def destroy

  end

  private

  def valid_album
    @album = current_user.albums.
        where( :id => params[:id] ).first
    render guilty_response unless @album
  end

  def valid_title
    @album = @user.albums.
        where( :title => params[:album_name] ).first
    redirect_to user_albums_path(@user)
  end


end
