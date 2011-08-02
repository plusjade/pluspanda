class CreateTweets < ActiveRecord::Migration
  def self.up
    create_table :tweets do |t|
      t.references  :user
      t.text        :data, :limit => 16777215

      t.integer     :position
      t.boolean     :publish, :default => false
      t.boolean     :trash, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :tweets
  end
end
