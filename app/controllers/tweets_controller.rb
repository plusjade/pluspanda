class TweetsController < ApplicationController
  
  layout proc { |c| c.request.xhr? ? false : "twitter"}
  before_filter :require_user, :setup_user

  def index
    @tweets = @user.tweets_as_api
    total = @user.tweets.where(:trash => false).count
    update_data = {
      "total" => total
    }

    respond_to do |format|
      format.any(:html, :iframe) { render :text => 'a standalone version maybe?'}
      format.json { 
        render :json => {
          :update_data  => update_data,
          :tweets => @tweets
        }
      }
      format.js do
        #@response.headers["Cache-Control"] = 'no-cache, must-revalidate'
        #@response.headers["Expires"] = 'Mon, 26 Jul 1997 05:00:00 GMT'
        render :js => "panda.display(#{@tweets.to_json});panda.update(#{update_data.to_json});"
      end
    end
  end
  
  
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
