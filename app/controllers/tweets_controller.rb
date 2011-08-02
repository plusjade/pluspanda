class TweetsController < ApplicationController
  
  layout proc { |c| c.request.xhr? ? false : "twitter"}
  before_filter :require_user, :setup_user

  def create
    uid = params[:url].scan(/[\d]+/).pop
    if uid
      tweet = @user.tweets.new(:tweet_uid => uid)
      if tweet.save
        @status  = "good"
        @message = "Tweet Added #{uid}"
        @resource = tweet
      else
        @message = tweet.errors.to_a.join(", ")
      end  
    else
      @message = "Unable to find tweet."
    end
    
    serve_json_response
  end
  
  def trash
    @tweet = @user.tweets.find(params[:id])
    if @tweet
      if @tweet.destroy
        @status = "good"
        @message = "Tweet trashed"
      else
        @message = @tweet.errors.to_a.join(", ")
      end
    else
      @message = "Invalid Tweet"
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
