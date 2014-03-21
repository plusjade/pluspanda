class StringNames < ActiveRecord::Migration
  def up
    add_column :themes, :theme_name, :string unless column_exists? :themes, :theme_name
    add_column :theme_attributes, :attribute_name, :string unless column_exists? :theme_attributes, :attribute_name
  end

  def down
    remove_column :theme_attributes, :attribute_name
  end
end
