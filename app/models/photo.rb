class NotRestrictedValidator < ActiveModel::EachValidator
  # You can`t register with restricted login!!!
  def validate_each(record, attribute, value)
    record.errors[attribute] << ": Using #{attribute} '#{value}' is forbidden, sorry" unless
        !User::RESTRICTED_LOGINS.index(value) #.find {|login| value =~ /#{login}/}
  end
end


class Photo < ActiveRecord::Base

  attr_accessible :user_id, :album_id, :photo, :views, :permissions

  belongs_to :album
  belongs_to :user # just to stay on a safe side, might be removed later
  has_many :photo_comments

  #<width>x<height><specifier>

  # % : Interpret width and height as a percentage of the current size
  # ! : Resize to width and height exactly, loosing original aspect ratio
  # < Resize only if the image is smaller than the geometry specification
  # > Resize only if the image is greater than the geometry specification
  # # : Crop!

  has_attached_file :photo, :styles => { :large => '600x400>', :medium => "300x200#", :thumb => "200x150>" }

  validates_presence_of :photo_file_name
  validates_presence_of :photo_content_type
  validates_presence_of :photo_file_size

  validates_attachment_content_type :photo,
                                    :content_type => ['image/jpeg', 'image/jpg',
                                                      'image/pjpeg', 'image/png', 'image/gif'],
                                    :message => 'wtf?',
                                    :unless => Proc.new  { |model| model.photo }
  validates_attachment_size :photo, :less_than => 4.megabytes, :unless => Proc.new { |model| model.photo }

  before_save :randomize_file_name, :if => :uploading_photo?
  after_post_process :save_photo_dimensions

  def restricted_items
    perms = eval(permissions)
    ratings = (perms[:gender] == "female")? PhotoRating::FEMALE_RATINGS : PhotoRating::MALE_RATINGS

    restricted = Proc.new {|category|
      ratings[category].map {|item| (perms[category].include? item)? nil : item}.compact
    }

    {:primary => restricted.call(:primary), :secondary => restricted.call(:secondary)}
  end

  def allowed_items
    perms = eval(permissions)
    {:primary => perms[:primary], :secondary => perms[:secondary]}
  end

  private

  def randomize_file_name
    extension = File.extname(photo_file_name).downcase
    self.photo.instance_write(:file_name, "#{ActiveSupport::SecureRandom.hex(16)}#{extension}")
  end

  def uploading_photo?
    photo_file_name_changed?
  end

  def save_photo_dimensions # See lib/attachment.rb for details
    if photo.geometry && photo.geometry.width > 100 && photo.geometry.height > 100
      self.photo_dimensions = {:original => {:width => photo.geometry.width, :height => photo.geometry.height},
                               :large => {:width => photo.geometry(:large).width, :height => photo.geometry(:large).height}}.to_s
    end
  end



end
