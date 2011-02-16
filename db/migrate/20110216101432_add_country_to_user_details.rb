class AddCountryToUserDetails < ActiveRecord::Migration
  def self.up
    add_column :user_details, :country, :string
    add_column :user_details, :city, :string
  end

  def self.down
    remove_column :user_details, :city
    remove_column :user_details, :country
  end
end
