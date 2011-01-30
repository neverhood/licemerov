class CreateRootEntries < ActiveRecord::Migration
  def self.up
    create_table :root_entries do |t|
      t.integer :user_id, :nil => false, :default => 0
      t.string :login, :nil => false, :default => ''
      t.integer :mood, :default => 0
      t.text :body, :nil => false, :default => ''
      t.string :avatar_url, :default => ''

      t.timestamps
    end
  end

  def self.down
    drop_table :root_entries
  end
end
