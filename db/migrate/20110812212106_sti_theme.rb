class StiTheme < ActiveRecord::Migration
  def self.up
    add_column :themes, :type, :string
  end

  def self.down
  end
end
