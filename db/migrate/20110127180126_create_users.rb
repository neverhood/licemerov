class CreateUsers < ActiveRecord::Migration
  def self.up
    # Basic user details
    create_table :users do |t|
      t.string :login, :null => false, :default => ''
      t.string :email, :null => false, :default => ''
      t.string :crypted_password, :null => false, :default => ''
      t.string :password_salt, :null => false, :default => ''
      t.string :persistence_token, :null => false, :default => ''
      t.string :single_access_token, :null => false, :default => ''
      t.string :perishable_token, :null => false, :default => ''
      t.integer :sex, :null => false, :default => 1

      # Avatar columns (paperclip)
      
      t.string :avatar_file_name
      t.string :avatar_content_type
      t.integer :avatar_file_size
      t.datetime :avatar_updated_at
      t.string :avatar_dimensions


      # MAGIC Columns

      t.integer :login_count, :null => false, :default => 0
      t.integer :failed_login_count, :null => false, :default => 0
      t.datetime :last_request_at
      t.datetime :current_login_at
      t.datetime :last_login_at
      t.string :current_login_ip
      t.string :last_login_ip

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
