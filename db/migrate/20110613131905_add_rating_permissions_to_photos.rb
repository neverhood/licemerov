class AddRatingPermissionsToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :permissions, :string
  end

  def self.down
    remove_column :photos, :permissions
  end
end
