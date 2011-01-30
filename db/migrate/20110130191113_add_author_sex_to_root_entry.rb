class AddAuthorSexToRootEntry < ActiveRecord::Migration
  def self.up
    add_column :root_entries, :author_sex, :integer
  end

  def self.down
    remove_column :root_entries, :author_sex
  end
end
