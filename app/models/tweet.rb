class Tweet < ActiveRecord::Base
  belongs_to :user
  
  validates_uniqueness_of :tweet_uid, :scope => :user_id, 
    :message => "You've already added this tweet!"
  validate :tweet_existance

  def tweet_existance
    self.data = get_tweet
    if self.data.empty?
      errors.add(:tweet_uid, "Tweet Not Found!")
    end
  end

  def data_json 
    YAML.load(self.data)
  end
  
  def get_tweet
    url = URI.parse("http://api.twitter.com")
    response = Net::HTTP.start(url.host, url.port) {|http|
      http.get("/1/statuses/show/#{self.tweet_uid}.json")
    }
    JSON.parse(response.body)    
  rescue Errno::ECONNREFUSED
    {}
  rescue Timeout::Error
    {}
  rescue JSON::ParserError
    {}
  end
  
end