class ExistentUserValidator < ActiveModel::EachValidator
  # Check if user exists
  def validate_each(record, attribute, value)
    record.errors[attribute] << "wrong #{attribute}" unless
        User.where(['id = ?', value.to_i]).count > 0
  end
end

class ExistentMessageValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << "wrong #{attribute}" unless
        value.nil? || (Message.where(['id = ?', value.to_i]).count > 0) 
  end
end

class Message < ActiveRecord::Base

  attr_accessor :recipients
  attr_accessible :parent_id, :receiver_id, :subject, :body, :recipient

  belongs_to :user
  belongs_to :receiver, :class_name => 'User', :foreign_key => 'receiver_id'

  validates :receiver_id, :existent_user => true

  # Parent_id is set once you reply someones message ( for messaging history purposes)
  # If the message you reply to already has parent_id (i.e. parent_id IS NOT NULL) - new message parent_id is set to it (
  # to just order by 'created_at DESC' later. if it IS NULL - the parent_id is set to parent message's ID
  
  validates :parent_id, :existent_message => true
  validates :body, :length => {:minimum => 2, :maximum => 1000 }
  validates :subject, :length => {:maximum => 200 }
  validate :not_sent_to_self


  private

  def not_sent_to_self
    self.errors.add(:receiver_id, 'Invalid attribute') if user_id == receiver_id
  end

end
