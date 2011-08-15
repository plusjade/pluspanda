class TweetsController < ApplicationController
  
  layout proc { |c| c.request.xhr? ? false : "twitter"}
  before_filter :require_user, :setup_user
  before_filter do
    @active_tag   = (params['tag'].nil?)  ? 'all'    : params['tag']
    @active_sort  = (params['sort'].nil?) ? 'newest' : params['sort'].downcase
    @active_page  = (params['page'].nil? ) ? 1       : params['page'].to_i 
  end
  
  def index
    offset = ( @active_page*@user.tweet_setting.per_page ) - @user.tweet_setting.per_page
    total = @user.tweets.where(:trash => false).count
    update_data = {"total" => total}
    
    if total > (offset + @user.tweet_setting.per_page)
      update_data["nextPageUrl"]  = root_url + tweets_path + ".js?apikey=" + @user.apikey + '&tag=' + @active_tag + '&sort=' + @active_sort + '&page=' + (@active_page + 1).to_s
      update_data["nextPage"]     = @active_page + 1
      update_data["tag"]          = @active_tag
      update_data["sort"]         = @active_sort
    end

    @tweets = @user.tweets.limit(@user.tweet_setting.per_page).offset(offset).as_api


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
  
  # PUT 
  # Save tweet_setting
  def settings
    if @user.tweet_setting.update_attributes(params[:tweet_setting])
      @status   = "good"
      @message  = "Settings updated"
      @resource = @user.tweet_setting
    elsif !@user.tweet_setting.valid?
      @message = "Oops! Please make sure all fields are valid!"
    end

    serve_json_response
    return
  end
  
end
