class AddPhoneToUserDetails < ActiveRecord::Migration
  def self.up
    add_column :user_details, :phone, :string
    add_column :user_details, :website, :string
  end

  def self.down
    remove_column :user_details, :website
    remove_column :user_details, :phone
  end
end
