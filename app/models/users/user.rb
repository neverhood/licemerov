class NotRestrictedValidator < ActiveModel::EachValidator
  # You can`t register with restricted login!!!
  def validate_each(record, attribute, value)
    record.errors[attribute] << ": Using #{attribute} '#{value}' is forbidden, sorry" unless
        !User::RESTRICTED_LOGINS.index(value) #.find {|login| value =~ /#{login}/}
  end
end

class User < ActiveRecord::Base

  validates :email, :presence => true, :uniqueness => true, :length => {:maximum => 25, :minimum => 5}
  validates :login, :presence => true, :uniqueness => true, :length => {:maximum => 15, :minimum => 3}, :not_restricted => true

  delegate :first_name, :first_name=, :last_name, :last_name=, :city, :city=, :country, :country=,
           :avatar, :avatar=, :phone, :phone=, :birth_date, :birth_date=, :website, :website=, :age, :to => :user_details

  has_one :user_details # e.g -> Name, gender etc

  # Pseudo many-to-many friendship relationship with joining table
  has_many :friendships
  has_many :inverse_friendships, :class_name => 'Friendship', :foreign_key => :friend_id

  # Make one db request instead of two ( for both direct and inverse friendships )
  # you must show it some love even though it's ugly
  scope :friends_of, proc {|user|
    joins("inner join (select f.user_id, f.friend_id from friendships f
              where ((f.user_id = #{user.id}) or (f.friend_id = #{user.id}))
              AND f.approved = 't' AND f.canceled = 'f') f
          on users.id = f.friend_id or users.id = f.user_id
          where users.id != #{user.id}") }

  scope :pending_friends_of, proc {|user|
    joins(:friendships).where(['friendships.friend_id = ?', user.id]).where(['approved = ?', false])
  }

  after_create :create_details

  acts_as_authentic { |config| config.login_field :login }

  # Array of restricted logins
  RESTRICTED_LOGINS = %w(main login user admin administrator index users photos attachments attachment
    photo user_session user_sessions logout register registration)

  # Friendships

  def friendship_with(user, options = {:approved => true})
    friendship = Friendship.where(['(user_id = ? AND friend_id = ?) OR (friend_id = ? AND user_id = ?)',
                                   self.id, user.id, self.id, user.id]).where(['canceled = ?', false])
    if options[:approved] != :all
      friendship = friendship.where(['approved = ?', options[:approved]]).first
    else
      friendship = friendship.first
    end
  end

  def gender
    self.sex == 0 ? 'female' : 'male'
  end

  # Alias to relation
  def details
    self.user_details
  end


  private

  def create_details
    self.create_user_details
  end


end
