class Album < ActiveRecord::Base

  belongs_to :user

  validates :title, :presence => true, :length => { :within => (2..25) }, :allow_blank => false
  validates :user_id, :presence => true, :numericality => true
  validates :description, :allow_blank => true, :length => { :within => (2..500) }

end
