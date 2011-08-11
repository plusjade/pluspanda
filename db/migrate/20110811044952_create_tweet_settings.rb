class CreateTweetSettings < ActiveRecord::Migration
  def self.up
    create_table :tweet_settings do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :tweet_settings
  end
end
