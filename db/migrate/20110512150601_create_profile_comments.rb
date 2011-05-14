class CreateProfileComments < ActiveRecord::Migration
  def self.up
    create_table :profile_comments do |t|
      t.integer :user_id, :null => false
      t.integer :author_id, :null => false
      t.integer :parent_id
      t.text :body, :null => false, :default => ''
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size

      t.timestamps
    end
  end

  def self.down
    drop_table :profile_comments
  end
end
