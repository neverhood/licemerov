class RemoveSexFromUserDetails < ActiveRecord::Migration
  def self.up
    remove_column :user_details, :sex
  end

  def self.down
    add_column :user_details, :sex, :integer, :default => 0
  end
end
