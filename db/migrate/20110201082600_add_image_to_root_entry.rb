class AddImageToRootEntry < ActiveRecord::Migration
  def self.up
    add_column :root_entries, :image_file_name, :string
    add_column :root_entries, :image_content_type, :string
    add_column :root_entries, :image_file_size, :integer
  end

  def self.down
    remove_column :root_entries, :image_file_size
    remove_column :root_entries, :image_content_type
    remove_column :root_entries, :image_file_name
  end
end
