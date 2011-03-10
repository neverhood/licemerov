class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :user_id
      t.integer :receiver_id
      t.string :user_login
      t.integer :user_sex
      t.boolean :read
      t.string :subject

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
