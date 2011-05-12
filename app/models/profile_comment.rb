class ProfileComment < ActiveRecord::Base

  attr_accessible :body, :image, :user_id

  belongs_to :user

  validates :body, :length => {:within => 1.1000}, :presence => true, :allow_blank => false

  has_attached_file :image, :styles => { :large => '600x400>', :medium => "300x200#", :thumb => "200x150>" }


  validates_attachment_content_type :image,
                                    :path => ":rails_root/public/system/profiles/:id/:style/:filename",
                                    :content_type => ['image/jpeg', 'image/jpg',
                                                      'image/pjpeg', 'image/png', 'image/gif'],
                                    :unless => Proc.new  { |model| model.image }


  validates_attachment_size :photo, :less_than => 4.megabytes, :unless => Proc.new { |model| model.image }

  before_save :randomize_file_name, :if => :uploading_image?


  private

  def uploading_image?
    image_file_name_changed?
  end

  def randomize_file_name
    extension = File.extname(image_file_name).downcase
    self.image.instance_write(:file_name, "#{ActiveSupport::SecureRandom.hex(16)}#{extension}")
  end
end
