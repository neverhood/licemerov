class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table :albums do |t|
      t.integer :user_id
      t.string :cover
      t.string :title
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :albums
  end
end
