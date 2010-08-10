class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.references :user
      t.string     :name
      t.string     :desc
      t.integer    :position
      t.timestamps
    end
  end

  def self.down
    drop_table :tags
  end
end
