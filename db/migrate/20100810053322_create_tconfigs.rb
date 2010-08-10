class CreateTconfigs < ActiveRecord::Migration
  def self.up
    create_table :tconfigs do |t|
      t.references  :user
      t.string      :theme
      t.string      :sort
      t.integer     :per_page
      t.text        :form
      t.text        :message
      t.timestamps
    end
  end

  def self.down
    drop_table :tconfigs
  end
end
