class Friendship < ActiveRecord::Base

  belongs_to :user
  belongs_to :friend, :class_name => 'User'

  validate :uniqueness

  private

  def uniqueness
    false if Friendship.where(['user_id = ?', user_id]).
      where(['friend_id', friend_id]).count > 0
  end

end
