#class ExistingValidator < ActiveModel::EachValidator
#  # You can`t register with restricted login!!!
#  def validate_each(record, attribute, value)
#    record.errors[attribute] << ": Using #{attribute} '#{value}' is forbidden, sorry" unless
#        !User::RESTRICTED_LOGINS.index(value) #.find {|login| value =~ /#{login}/}
#  end
#end

class RootEntry < ActiveRecord::Base

  validates :body, :presence => true, :length => {:minimum => 2, :maximum => 150}

  has_attached_file :image,
                    #:path => Settings.services.assets.path,
                    #:url => Settings.services.assets.url,
                    :default_style => :regular,
                    #:default_url =>
                    #    Settings.services.assets.defaults_path,
                    #:whiny_thumbnails => true,
                    :styles => {
                        :regular => ['300x300>', :jpg],
                        :enlarged => ['400x400>', :jpg],
                    }
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/pjpeg', 'image/png', 'image/gif'],
                                    :unless => Proc.new  { |model| model.image }
  validates_attachment_size :image, :less_than => 1.megabytes, :unless => Proc.new { |model| model.image }

  before_create :randomize_file_name, :if => :uploading_image?

  def author
    User.where(:id => self.user_id).first
  end

  def type
    self.parent? ? 'parent' : 'response'
  end

  def type_partial
    self.parent? ? 'main/entries/parent' : 'main/entries/response'
  end

  def parent?
    self.parent_id.nil?
  end

  def children
    return @children if defined?(@children)
    @children = RootEntry.where(:parent_id => self.id).all
  end

  def author_gender
    self.author_sex == 0 ? 'female' : 'male'
  end

  private

  def uploading_image?
    !image_file_name.nil?
  end

  def randomize_file_name
    extension = File.extname(image_file_name).downcase
    self.image.instance_write(:file_name, "#{ActiveSupport::SecureRandom.hex(16)}#{extension}")
  end

end
