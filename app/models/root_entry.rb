
class RootEntry < ActiveRecord::Base

  include Pagination::Model

  validates :body, :presence => true, :length => {:minimum => 1, :maximum => 1000}

  attr_accessible :mood, :body, :parent_id, :image

  belongs_to :user


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

  before_destroy proc {|comment| comment.children.each {|response| response.destroy }}
  before_create :randomize_file_name, :if => :uploading_image?

  scope :with_user_details, select("'root_entries'.*, 'users'.sex, 'users'.avatar_file_name,
           'users'.avatar_updated_at, 'users'.login").
      joins(:user)

  scope :parent, where(:parent_id => nil)
  scope :response, where('"root_entries".parent_id IS NOT NULL')

  scope :latest_responses, proc {
      |parent_id, limit| where(:parent_id => parent_id).
        with_user_details.
        order("'root_entries'.created_at DESC").
        limit(limit)
  }

  def author
    User.where(:id => self.user_id).first
  end

  def author_avatar(style = 'thumb')
    if avatar_file_name
      "/system/avatars/#{user_id}/#{style}/#{self.avatar_file_name}?#{self.avatar_updated_at.to_time.to_i.to_s}"
    else
      "/avatars/#{style}/missing.png"
    end
  end

  def type
    self.parent? ? 'parent' : 'response'
  end

  def type_partial
    self.parent? ? 'main/parent' : 'main/response'
  end

  def parent?
    self.parent_id.nil?
  end

  def children
    return @children if defined?(@children)
    @children = RootEntry.with_user_details.where(:parent_id => self.id)
  end

  def responses(filter = :latest)
    if filter == :latest
      self.class.latest_responses(self.id, 3)
    elsif filter == :all
      self.class.latest_responses(self.id, 100)
    end
  end

  def author_gender
    self.sex == 0 ? 'female' : 'male'
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
