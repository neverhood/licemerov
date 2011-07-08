class PhotosController < ApplicationController

  before_filter :require_user, :only => [:create, :update, :destroy]
  before_filter :existent_user, :only => [:show, :show_more]
  before_filter :coerce_params, :only => :create
  before_filter :set_permissions, :only => :create
  before_filter :more_photos, :only => :show_more
  before_filter :existent_photo, :only => [:show, :update]

  layout Proc.new { |controller| controller.request.xhr?? false : 'application' }

  def show
    @comments = {:photo_comments => PhotoComment.of(@photo).order("'photo_comments'.created_at DESC").
        limit(10).map { |c| json_for(c)[:photo_comment] }}
    @items = {:items => render_to_string(:partial => 'photos/ratings')}
    @items_json = {:permissions => {:allowed => eval(@photo.permissions)[:primary], :restricted => @photo.restricted_items[:primary] }}
    respond_to do |format|
      @photo.update_attributes(:views => @photo.views + 1)
      format.json {
        render :json =>{:photo => @photo.photo.url(:large)}.
            merge(@comments).   # photo comments
            merge(@items).      # partial with ratings items
            merge(@items_json)  # e.g: {allowed:['face', 'ass'...], restricted:['legs', 'belly'..]}
      }
    end
  end

  def show_more
    if @photos
      respond_to do |format|
        format.json { render :json => {:photos => @photos}}
      end
    end
  end

  def create
    @upload = Photo.new(params[:photo].merge({:user_id => current_user.id, :permissions => @photo_permissions}))
    @upload.save
    respond_to do |format|
      format.json { render :json => json_for(@upload), :status => 200 }
    end
  end

  def update

  end

  def destroy

  end

  private

  def more_photos
    if params[:photos_count]
      photos_count = params[:photos_count].to_i
      if photos_count >= 30
        @photos = @user.photos.offset(photos_count).limit(30).order("'photos'.created_at DESC").map { |p| json_for(p)[:photo]}
      end
    end
  end

  def existent_photo
    @photo = @user.photos.where(['photos.id = ?', params[:id]]).first
    (render :nothing => true) unless @photo
  end

  def coerce_params
    if params[:photo].nil?
      params[:photo] =
          Hash[[
                   [:user_id, current_user.id], [:album_id, params[:album_id]],
                   [:photo, params[:Filedata]]
               ]]
      params[:photo][:photo].content_type = MIME::Types.type_for(params[:photo][:photo].original_filename).to_s
    end
  end

  # Allowed items
  def set_permissions
    ratings = (current_user.sex == 0)? PhotoRating::FEMALE_RATINGS : PhotoRating::MALE_RATINGS
    @photo_permissions = {
        :primary => ratings[:primary],
        :secondary => [],
        :gender => current_user.gender
    }.to_s
  end

end
