class PredefinedCountryValidator < ActiveModel::EachValidator
  # You can`t register with restricted country!!!
  def validate_each(record, attribute, value)
    record.errors[attribute] << ": Using #{attribute} '#{value}' is forbidden, sorry" unless
        Countries.where(:name => value).first || value.nil? || value.blank?
  end
end

class UserDetails < ActiveRecord::Base

  attr_accessible :first_name, :last_name, :birth_date, :country, :city, :avatar, 
     :phone, :website


  
  validates :country, :predefined_country => true
  validates :city, :length => {:maximum => 25}



  def age
    Time.now.year - birth_date.year - (birth_date.change(:year => Time.now.year) > Time.now ? 1 : 0) unless birth_date.nil?
  end

  def country_origin
    Countries.where(:name => self.country).first
  end



  private


end
