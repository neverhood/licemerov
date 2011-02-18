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
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/pjpeg', 'image/png', 'image/gif'],
                                    :unless => Proc.new  { |model| model.avatar }
  validates_attachment_size :avatar, :less_than => 1.megabytes, :unless => Proc.new { |model| model.avatar }

  validates :country, :predefined_country => true
  validates :city, :length => {:maximum => 25}
#  validates :city, :existance => false, :length => {:minimum => 3, :maximum => 25}

  def age
    Time.now.year - birth_date.year - (birth_date.change(:year => Time.now.year) > Time.now ? 1 : 0) unless birth_date.nil?
  end

  def country_origin
    Countries.where(:name => self.country).first
  end

  def avatar_geometry(style = :original)
    @geometry ||= Hash.new
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar.path(style))
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  private

  def reprocess_avatar
    avatar.reprocess!
  end

end
