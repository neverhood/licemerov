class PredefinedCountryValidator < ActiveModel::EachValidator
  # You can`t register with restricted login!!!
  def validate_each(record, attribute, value)
    record.errors[attribute] << ": Using #{attribute} '#{value}' is forbidden, sorry" unless
        Countries.where(:name => value).first
  end
end

class UserDetails < ActiveRecord::Base

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  belongs_to :user
  delegate :sex, :sex=, :to => :user

  after_update :reprocess_avatar, :if => :cropping?

  has_attached_file :avatar,
                    #:path => Settings.services.assets.path,
                    #:url => Settings.services.assets.url,
                    :default_style => :thumb,
                    #:default_url =>
                    #    Settings.services.assets.defaults_path,
                    #:whiny_thumbnails => true,
                    :styles => {
                        :thumb => {:geometry => "110x110>", :format => :jpg, :processors => [:cropper]},
                        :small => {:geometry => "200x200>", :format => :jpg, :processors => [:cropper]},
                        :for_cropping => ['600x600>', :jpg]
                    }
  after_post_process :save_avatar_dimensions

  validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/pjpeg', 'image/png', 'image/gif'],
                                    :unless => Proc.new  { |model| model.avatar }
  validates_attachment_size :avatar, :less_than => 1.megabytes, :unless => Proc.new { |model| model.avatar }

  validates :country, :predefined_country => true
  validates :city, :length => {:maximum => 25}


  def age
    Time.now.year - birth_date.year - (birth_date.change(:year => Time.now.year) > Time.now ? 1 : 0) unless birth_date.nil?
  end

  def country_origin
    Countries.where(:name => self.country).first
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def new_avatar?
    self.avatar_file_name_changed?
  end

  private

  def reprocess_avatar
    avatar.reprocess!
  end

  def save_avatar_dimensions
    original_geo, cropping_geo = avatar_geometry, avatar_geometry(:for_cropping)
    self.avatar_dimensions = {:original => {:width => original_geo.width, :height => original_geo.height},
                              :for_cropping => {:width => cropping_geo.width, :height => cropping_geo.height}}.to_s
  end

  def avatar_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar.queued_for_write[style])
  end


end
