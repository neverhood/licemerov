class Album < ActiveRecord::Base

  attr_accessible :title, :description

  belongs_to :user

  validates :title, :presence => true, :length => { :within => (2..25) },
            :allow_blank => false, :uniqueness => { :scope => :user_id }
  validates :user_id, :presence => true, :numericality => true
  validates :description, :allow_blank => true, :length => { :within => (2..500) }

end
