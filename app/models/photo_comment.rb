class PhotoComment < ActiveRecord::Base

  include Pagination::Model

  belongs_to :photo
  belongs_to :user

  attr_accessible :body

  validates :body, :length => {:within => 1..1000}, :presence => true, :allow_blank => false

  scope :with_user_details, select("'photo_comments'.*, 'users'.sex, 'users'.avatar_file_name,
           'users'.avatar_updated_at, 'users'.login").
      joins(:user)

  scope :of, proc {|photo| with_user_details.where(:photo_id => photo.id) }

  def author_avatar(style)
    if avatar_file_name
      "/system/avatars/#{user_id}/#{style}/#{self.avatar_file_name}?#{self.avatar_updated_at.to_time.to_i.to_s}"
    else
      "/avatars/#{style}/missing.png"
    end
  end

  def parent?
    true
  end

  def author_gender
    self.sex == 0 ? 'female' : 'male'
  end

end
