class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.integer :user_id, :nil => false, :default => 0
      t.integer :friend_id, :nil => false, :default => 0
      t.boolean :approved, :default => false
      t.boolean :canceled, :default => false
      t.boolean :marked_as_deleted, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :friendships
  end
end
