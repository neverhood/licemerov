class CreatePhotoRatings < ActiveRecord::Migration
  def self.up
    create_table :photo_ratings do |t|
      t.integer :photo_id
      t.integer :rater_id
      t.integer :user_id
      t.integer :rating
      t.string :item

      t.timestamps
    end
  end

  def self.down
    drop_table :photo_ratings
  end
end
