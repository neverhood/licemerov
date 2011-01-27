# You can`t register with restricted login!!!
#
class NotRestrictedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << "Using '#{value}' is forbidden, sorry" unless !User::RESTRICTED_LOGINS.index(value.to_sym)
  end
end

class User < ActiveRecord::Base

  validates :email, :presence => true, :uniqueness => true, :length => {:maximum => 25, :minimum => 5}
  validates :login, :presence => true, :uniqueness => true, :length => {:maximum => 15, :minimum => 4}, :not_restricted => true

  has_one :user_details # e.g -> Name, gender etc

  acts_as_authentic { |config| config.login_field :login }

  # Array of restricted logins
  RESTRICTED_LOGINS = [:login, :user, :admin, :administrator, :main, :index, :users, :photos, :attachments, :attachment,
    :photo, :user_session, :user_sessions, :logout, :register, :registration]


  # Alias to relation
  def details
    self.user_details
  end

  def home_page
    user_profile_url(:user_profile => self.login)
  end

end
