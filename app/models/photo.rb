class Photo < ActiveRecord::Base

  attr_accessible :user_id, :album_id, :photo

  belongs_to :album
  belongs_to :user # just to stay on a safe side, might be removed later

  #<width>x<height><specifier>

  # % : Interpret width and height as a percentage of the current size
  # ! : Resize to width and height exactly, loosing original aspect ratio
  # < Resize only if the image is smaller than the geometry specification
  # > Resize only if the image is greater than the geometry specification
  # # : Crop!

  has_attached_file :photo, :styles => { :large => '400x400>', :medium => "300x200#", :thumb => "100x100>" }

  before_save :randomize_file_name, :if => :uploading_photo?
  after_post_process :save_photo_dimensions

  private

  # TODO: save dimensions

  def randomize_file_name
    extension = File.extname(photo_file_name).downcase
    self.photo.instance_write(:file_name, "#{ActiveSupport::SecureRandom.hex(16)}#{extension}")
  end

  def uploading_photo?
    photo_file_name_changed?
  end

  def save_photo_dimensions # See lib/attachment.rb for details
    if photo.geometry.width > 100 && photo.geometry.height > 100
      self.photo_dimensions = {:original => {:width => photo.geometry.width, :height => photo.geometry.height},
                                :large => {:width => photo.geometry(:large).width, :height => photo.geometry(:large).height}}.to_s
    end
  end

end
