class TweetsController < ApplicationController
  
  layout proc { |c| c.request.xhr? ? false : "twitter"}
  before_filter :require_user, :setup_user

  def create
    match = params[:url].match(/[\d]+/)
    if match
      tweet = @user.tweets.new(:tweet_uid => match[0])
      if tweet.save
        @status  = "good"
        @message = "Tweet Added #{match[0]}"
      else
        @message = tweet.errors.to_a.join(", ")
      end  
    else
      @message = "Unable to find tweet."
    end
    
    serve_json_response
  end
  
  
  def save_positions
    if params['tweet'] && params['tweet'].is_a?(Array) 
      t_hash  = {}
      ids     = params['tweet'].map! { |id| id.to_i }
      @user.tweets.find(ids).map { |t| t_hash[t.id.to_s] = t }
      ids.each_with_index do |id, position|
        t_hash[id.to_s].update_attribute(:position, position)
      end
    
      @status  = "good"
      @message = "Positions Saved!"
    end
    
    serve_json_response
  end
  
end
