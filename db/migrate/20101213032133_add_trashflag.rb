class AddTrashflag < ActiveRecord::Migration
  def self.up
    add_column :testimonials, :trash, :boolean, :default => false
  end

  def self.down
    remove_column :testimonials, :trash
  end
end
