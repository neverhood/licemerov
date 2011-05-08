class Photo < ActiveRecord::Base

  attr_accessible :user_id, :album_id, :photo

  belongs_to :album
  belongs_to :user # just to stay on a safe side, might be removed later

  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "100x100>" }

  before_save :randomize_file_name, :if => :uploading_photo?

  private

  # TODO: save dimensions

  def randomize_file_name
    extension = File.extname(photo_file_name).downcase
    self.photo.instance_write(:file_name, "#{ActiveSupport::SecureRandom.hex(16)}#{extension}")
  end

  def uploading_photo?
    photo_file_name_changed?
  end

end
