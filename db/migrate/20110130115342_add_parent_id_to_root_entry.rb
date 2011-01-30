class AddParentIdToRootEntry < ActiveRecord::Migration
  def self.up
    add_column :root_entries, :parent_id, :integer
  end

  def self.down
    remove_column :root_entries, :parent_id
  end
end
