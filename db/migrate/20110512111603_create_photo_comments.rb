class CreatePhotoComments < ActiveRecord::Migration
  def self.up
    create_table :photo_comments do |t|
      t.integer :user_id
      t.integer :photo_id
      t.string :user_avatar_url
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :photo_comments
  end
end
