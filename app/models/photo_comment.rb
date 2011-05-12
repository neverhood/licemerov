class PhotoComment < ActiveRecord::Base

  belongs_to :photo
  belongs_to :user

  attr_accessor :body

  validates :body, :length => {:within => 1..1000}, :presence => true, :allow_blank => false
  
end
