class StringNames < ActiveRecord::Migration
  def up
    add_column :themes, :theme_name, :string
    add_column :theme_attributes, :attribute_name, :string
  end

  def down
    remove_column :theme_attributes, :attribute_name
  end
end
