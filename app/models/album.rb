class Album < ActiveRecord::Base

  attr_accessible :title, :description

  belongs_to :user

  validates :latinized_title, :presence => true, :length => { :within => (2..25) },
            :allow_blank => false, :uniqueness => { :scope => :user_id }

  validates :user_id, :presence => true, :numericality => true
  validates :description, :allow_blank => true, :length => { :within => (2..500) }

  has_many :photos, :dependent => :destroy
 # def to_param
#    latinized_title
 # end

  before_validation proc { |album| album.latinized_title = album.title.translit.parameterize }

  private


end
