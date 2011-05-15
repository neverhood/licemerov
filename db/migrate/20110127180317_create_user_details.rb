class CreateUserDetails < ActiveRecord::Migration

  def self.up
    create_table :user_details do |t|

      t.integer :user_id # Foreign key for 'users' table
      t.string :first_name # First name
      t.string :last_name # Last Name
      t.date :birth_date
      t.string :country
      t.string :city
      t.string :phone
      t.string :website


      t.timestamps
    end
  end

  def self.down
    drop_table :user_details
  end
end
