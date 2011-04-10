class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table :albums do |t|
      t.integer :user_id, :null => false, :default => 0
      t.string :cover, :default => '/images/missing.png'
      t.string :title, :null => false, :default => ''
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :albums
  end
end
