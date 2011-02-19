class PredefinedCountryValidator < ActiveModel::EachValidator
  # You can`t register with restricted login!!!
  def validate_each(record, attribute, value)
    record.errors[attribute] << ": Using #{attribute} '#{value}' is forbidden, sorry" unless
        Countries.where(:name => value).first || value.nil? || value.blank?
  end
end

class UserDetails < ActiveRecord::Base

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  belongs_to :user

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
                        :large => ['600x600>', :jpg]
                    }
  after_post_process :save_avatar_dimensions

  validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/pjpeg', 'image/png', 'image/gif'],
                                    :unless => Proc.new  { |model| model.avatar }
  validates_attachment_size :avatar, :less_than => 1.megabytes, :unless => Proc.new { |model| model.avatar }

  validates :country, :predefined_country => true
  validates :city, :length => {:maximum => 25}
  validate :avatar_geometry


  def age
    Time.now.year - birth_date.year - (birth_date.change(:year => Time.now.year) > Time.now ? 1 : 0) unless birth_date.nil?
  end

  def country_origin
    Countries.where(:name => self.country).first
  end

  def cropping?
    ![crop_x, crop_y, crop_w, crop_h].find {|a| !a.is_a? Fixnum }.nil?
  end

  private

  def reprocess_avatar
    avatar.reprocess!
  end

  def save_avatar_dimensions # See lib/attachment.rb for details
    if avatar.geometry.width > 100 && avatar.geometry.height > 100
      self.avatar_dimensions = {:original => {:width => avatar.geometry.width, :height => avatar.geometry.height},
                                :large => {:width => avatar.geometry(:large).width, :height => avatar.geometry(:large).height}}.to_s
    end
  end

  def avatar_geometry
    if self.avatar_file_name_changed?
      self.errors.add(:avatar,
              'is too small( should be at least 100x100 px image)') if (avatar.geometry.height < 100 || avatar.geometry.width < 100)
    end
  end

end
