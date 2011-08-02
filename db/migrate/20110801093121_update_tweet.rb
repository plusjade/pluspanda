class UpdateTweet < ActiveRecord::Migration
  def self.up

    add_column :tweets, :tweet_uid, :string
  end

  def self.down
  end
end
