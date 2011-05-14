class CreatePhotoComments < ActiveRecord::Migration
  def self.up
    create_table :photo_comments do |t|
      t.integer :user_id, :null => false
      t.integer :photo_id, :null => false
      t.text :body, :null => false, :default => ''

      t.timestamps
    end
  end

  def self.down
    drop_table :photo_comments
  end
end
