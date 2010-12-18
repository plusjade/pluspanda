class CreateThemeAttributes < ActiveRecord::Migration
  def self.up
    create_table :theme_attributes do |t|
      t.references  :theme
      t.integer     :type
      t.text        :published
      t.text        :staged
      t.text        :original
      t.timestamps
    end    
  end

  def self.down
    drop_table :theme_attributes
  end
end
