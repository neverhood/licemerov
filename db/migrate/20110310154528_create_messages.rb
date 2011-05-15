class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :user_id, :null => false, :default => 0
      t.integer :receiver_id, :null => false, :default => 0
      t.boolean :read, :null => false, :default => false
      t.text :body, :null => false, :default => ''
      t.string :subject
      t.boolean :marked_as_deleted, :null => false, :default => false
      t.integer :parent_id

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
