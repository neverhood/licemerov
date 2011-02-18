class AddAvatarDimensionsToUserDetails < ActiveRecord::Migration
  def self.up
    add_column :user_details, :avatar_dimensions, :string
  end

  def self.down
    remove_column :user_details, :avatar_dimensions
  end
end
