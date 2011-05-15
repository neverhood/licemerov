class CreateRootEntries < ActiveRecord::Migration
  def self.up
    create_table :root_entries do |t|
      t.integer :user_id, :nil => false, :default => 0
      t.integer :mood, :default => 0
      t.text :body, :nil => false, :default => ''
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.integer :parent_id

      t.timestamps
    end
  end

  def self.down
    drop_table :root_entries
  end
end
