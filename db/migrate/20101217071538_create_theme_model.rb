class CreateThemeModel < ActiveRecord::Migration
  
  def self.up
    create_table :themes do |t|
      t.references  :user
      t.integer     :theme
      t.boolean     :staged
      t.boolean     :published
      t.timestamps
    end
  end

  def self.down
    drop_table :theme
  end
  
end
