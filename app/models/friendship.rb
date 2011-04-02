class ExistentUserValidator < ActiveModel::EachValidator
  # Check if user exists
  def validate_each(record, attribute, value)
    record.errors[attribute] << "wrong #{attribute}" unless
        User.where(['id = ?', value.to_i]).count > 0
  end
end



class Friendship < ActiveRecord::Base

  attr_accessible :friend_id

  belongs_to :user
  belongs_to :friend, :class_name => 'User'

  validates :user_id, :presence => true, :numericality => true, :on => :create
  validates :friend_id, :presence => true, :numericality => true, :existent_user => true, :on => :create

  validate :uniq_combination, :on => :create

  # Look for existent friendship before creating one
  scope :unique_combination, proc {|user_id, friend_id|
    where(['(user_id = ? OR user_id = ?) AND (friend_id = ? OR friend_id = ?)',
           user_id, friend_id, user_id, friend_id]) }

  # joining query, check User model
  scope :friendships_of, proc {|user|
    select('friend_id, user_id').
        where(['((user_id = ?) or (friend_id = ?))', user.id, user.id]).
        where(['approved = ?', true]).where(['canceled = ?', false])
  }

  private

  def uniq_combination
    errors[:user_id] << 'wrong attribute' if Friendship.unique_combination(user_id, friend_id).count > 0
  end
end
