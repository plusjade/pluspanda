class TweetSettings < ActiveRecord::Migration
  def self.up
    create_table :tweet_settings do |t|
      t.references  :user
      t.string      :theme
      t.string      :sort
      t.integer     :per_page
      t.timestamps
    end
  end

  def self.down
    drop_table :tweet_settings
  end
end
