class RemoveUserLoginFromMessages < ActiveRecord::Migration
  def self.up
    remove_column :messages, :user_login
    remove_column :messages, :user_sex
  end

  def self.down
    add_column :messages, :user_login, :string
    add_column :messages, :user_sex, :integer
  end
end
