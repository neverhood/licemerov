class AddLatinizedTitleToAlbums < ActiveRecord::Migration
  def self.up
    add_column :albums, :latinized_title, :string
  end

  def self.down
    remove_column :albums, :latinized_title
  end
end
