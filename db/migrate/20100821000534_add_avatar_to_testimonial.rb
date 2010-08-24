class AddAvatarToTestimonial < ActiveRecord::Migration
  def self.up
    add_column :testimonials, :avatar_file_name, :string, :default => '', :null => false
  end

  def self.down
    remove_column :testimonials, :avatar_file_name
  end
end
