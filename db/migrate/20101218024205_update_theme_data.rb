class UpdateThemeData < ActiveRecord::Migration
  def self.up

    change_column(:themes, :theme, :integer, :limit => 5,  :required => true)
    change_column(:themes, :staged, :boolean, :default => false)
    change_column(:themes, :published, :boolean, :default => false)
    change_column(:theme_attributes, :type, :integer, :limit => 5,  :required => true)
    rename_column :theme_attributes, :type, :name
    rename_column :themes, :theme, :name
  end

  def self.down
    rename_column :theme_attributes, :name, :type

  end
end
