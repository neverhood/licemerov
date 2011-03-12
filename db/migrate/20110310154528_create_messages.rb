class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :user_id, :nil => false, :default => 0
      t.integer :receiver_id, :nil => false, :default => 0
      t.string :user_login, :nil => false, :default => ''
      t.integer :user_sex, :nil => false, :default => 0
      t.boolean :read, :nil => false, :default => false
      t.text :body, :nil => false, :default => ''
      t.string :subject
      t.boolean :marked_as_deleted, :nil => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
