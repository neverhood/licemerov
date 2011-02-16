class PredefinedCountryValidator < ActiveModel::EachValidator
  # You can`t register with restricted login!!!
  def validate_each(record, attribute, value)
    record.errors[attribute] << ": Using #{attribute} '#{value}' is forbidden, sorry" unless
        Countries.where(:name => value).first || value.nil? #.find {|login| value =~ /#{login}/}
  end
end

class UserDetails < ActiveRecord::Base

  belongs_to :user
  delegate :sex, :sex=, :to => :user

  has_attached_file :avatar,
                    #:path => Settings.services.assets.path,
                    #:url => Settings.services.assets.url,
                    :default_style => :regular,
                    #:default_url =>
                    #    Settings.services.assets.defaults_path,
                    #:whiny_thumbnails => true,
                    :styles => {
                        :thumb => ['100x100#', :jpg],
                        :regular => ['300x200>', :jpg],
                        :enlarged => ['400x300>', :jpg],
                    }
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/pjpeg', 'image/png', 'image/gif'],
                                    :unless => Proc.new  { |model| model.avatar }
  validates_attachment_size :avatar, :less_than => 1.megabytes, :unless => Proc.new { |model| model.avatar }

  validates :country, :predefined_country => true

  def country_origin
    Countries.where(:name => self.country).first
  end

  private


end
