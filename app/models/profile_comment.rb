class ProfileComment < ActiveRecord::Base

  include Pagination::Model

  attr_accessible :body, :image, :parent_id, :user_id

  belongs_to :user

  validates :body, :length => {:within => 1..1000}, :presence => true, :allow_blank => false
  validates :user_id, :presence => true, :allow_blank => false

  has_attached_file :image, :styles => {
      :regular => ['300x300>', :jpg],
      :enlarged => ['400x400>', :jpg],
  }


  validates_attachment_content_type :image,
                                    :path => ":rails_root/public/system/profiles/:id/:style/:filename",
                                    :url => "/system/profiles/:id/:style/:filename",
                                    :content_type => ['image/jpeg', 'image/jpg',
                                                      'image/pjpeg', 'image/png', 'image/gif'],
                                    :unless => Proc.new  { |model| model.image }


  validates_attachment_size :photo, :less_than => 4.megabytes, :unless => Proc.new { |model| model.image }

  before_save :randomize_file_name, :if => :uploading_image?

  scope :with_user_details, select("'profile_comments'.*, 'users'.sex, 'users'.avatar_file_name,
           'users'.avatar_updated_at, 'users'.login").
      joins(:user)
  scope :parent, where(:parent_id => nil)

  scope :latest_responses, proc {
      |parent_id, limit| where(:parent_id => parent_id).
        with_user_details.
        order("'profile_comments'.created_at DESC").
        limit(limit)
  }

  before_destroy proc {|comment| comment.children.each {|response| response.destroy }}


  def type
    self.parent? ? 'parent' : 'response'
  end

  def type_partial
    self.parent? ? 'profile_comments/parent' : 'profile_comments/response'
  end

  def parent?
    self.parent_id.nil?
  end

  def responses(filter = :latest)
    if filter == :latest
      self.class.latest_responses(self.id, 3)
    elsif filter == :all
      self.class.latest_responses(self.id, 100)
    end
  end



  def children
    return @children if defined?(@children)
    @children = ProfileComment.with_user_details.where(:parent_id => self.id)
  end

  def author_avatar(style)
    if avatar_file_name
      "/system/avatars/#{user_id}/#{style}/#{self.avatar_file_name}?#{self.avatar_updated_at.to_time.to_i.to_s}"
    else
      "/avatars/#{style}/missing.png"
    end
  end

  def author_gender
    self.sex == 0 ? 'female' : 'male'
  end


  private

  def uploading_image?
    image_file_name_changed?
  end

  def randomize_file_name
    extension = File.extname(image_file_name).downcase
    self.image.instance_write(:file_name, "#{ActiveSupport::SecureRandom.hex(16)}#{extension}")
  end
end
