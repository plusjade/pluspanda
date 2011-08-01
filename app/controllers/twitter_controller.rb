class TwitterController < ApplicationController

  layout proc { |c| c.request.xhr? ? false : "twitter"}
  before_filter :require_user, :setup_user

  # this is so we are always loading admin pages through sammy.js
  #before_filter :as_admin_page, :only => [:widget, :manage, :install, :collect]

  def index

  end

  def widget

  end

  def manage
    tweet = '{"in_reply_to_user_id":null,"user":{"show_all_inline_media":false,"follow_request_sent":false,"geo_enabled":false,"profile_use_background_image":true,"favourites_count":0,"protected":false,"url":"http:\/\/www.barackobama.com","profile_background_color":"77b0dc","name":"Barack Obama","id_str":"813286","profile_background_image_url":"http:\/\/a2.twimg.com\/profile_background_images\/272273809\/2012background_less.jpg","created_at":"Mon Mar 05 22:08:25 +0000 2007","statuses_count":1653,"notifications":false,"utc_offset":-18000,"followers_count":9393620,"listed_count":150823,"profile_background_image_url_https":"https:\/\/si0.twimg.com\/profile_background_images\/272273809\/2012background_less.jpg","profile_text_color":"333333","default_profile":false,"lang":"en","profile_sidebar_fill_color":"c2e0f6","profile_image_url_https":"https:\/\/si0.twimg.com\/profile_images\/1400727240\/o2012_twitter_normal.jpg","profile_background_tile":false,"profile_image_url":"http:\/\/a1.twimg.com\/profile_images\/1400727240\/o2012_twitter_normal.jpg","description":"This account is run by #Obama2012 campaign staff. Tweets from the President are signed -BO.\r\n","contributors_enabled":false,"default_profile_image":false,"verified":true,"profile_link_color":"2574ad","screen_name":"BarackObama","friends_count":692380,"profile_sidebar_border_color":"c2e0f6","location":"Washington, DC","id":813286,"is_translator":false,"following":true,"time_zone":"Eastern Time (US & Canada)"},"favorited":false,"in_reply_to_status_id_str":null,"id_str":"97691024717127680","created_at":"Sun Jul 31 15:32:09 +0000 2011","in_reply_to_screen_name":null,"in_reply_to_user_id_str":null,"truncated":false,"contributors":null,"retweeted":false,"text":"How will the administration\'s new fuel efficiency standards help your wallet and our environment? Take a look: http:\/\/t.co\/5RDh3ap","place":null,"in_reply_to_status_id":null,"retweet_count":"100+","source":"web","geo":null,"id":97691024717127680,"possibly_sensitive":false,"coordinates":null}'
    @tweet = ActiveSupport::JSON.decode(tweet)
    puts @tweet.to_yaml
  end

  def install  

  end

  def collect

  end


  def staged
    @css = @user.get_attribute("style.css").staged

    @theme_config = @user.generate_theme_config(true)

    render :template => "admin/staged", :layout => "staged"
  end

  def published
    render :template => "admin/published", :layout => "published"
  end

  # PUT 
  # Save tconfig settings #note rename to user.settings
  def settings
    if @user.tconfig.update_attributes(params[:tconfig])
      @status   = "good"
      @message  = "Settings updated"
      @resource = @user.tconfig
    elsif !@user.tconfig.valid?
      @message = "Oops! Please make sure all fields are valid!"
    end

    serve_json_response
    return
  end


#### testimonial stuff ####

  # GET    
  def testimonials
    order = "created_at DESC"

    case params[:filter]
    when "published"
      where = {:publish => true, :trash => false}
      order = "position ASC" if @user.tconfig.sort == 'position'
    when "hidden"
      where = {:publish => false, :trash => false}
    when "trash"
      where = {:trash => true}
    else
      where = { :created_at => (Time.now - 2.day)..Time.now, :trash => false }
    end

    render @user.testimonials.where(where).order(order)
    return

  end

  # GET
  # admin/testimonials/update
  def update
    unless ['publish', 'hide', 'lock', 'unlock', 'trash', 'untrash'].include?(params[:do])
      @message = "Invalid action."
      serve_json_response
      return
    end

    ids = params[:id].map! { |id| id.to_i }

    case params[:do]
    when "publish"
      updates = {:publish => true}
    when "hide"
      updates = {:publish => false}
    when "lock"
      updates = {:lock => true}
    when "unlock"
      updates = {:lock => false}
    when "tag"
      updates = {:tag => params[:tag].to_i}
    when "trash"
      updates = {:trash => true}
    when "untrash"
      updates = {:trash => false}  
    end
    count = @user.testimonials.update_all(updates, :id => ids)

    @status  = "good"
    @message = "#{count} Testimonials update with: #{params[:do]}"
    serve_json_response
    return   
  end 

  # GET
  # admin/testimonials/save_positions
  def save_positions
    if params['tstml'].nil? or !params['tstml'].is_a?(Array) 
      serve_json_response
      return
    end

    t_hash  = {}
    ids     = params['tstml'].map! { |id| id.to_i }
    @user.testimonials.find(ids).map { |t| t_hash[t.id.to_s] = t }
    ids.each_with_index do |id, position|
      t = t_hash[id.to_s]
      t.position = position
      t.save
    end

    @status  = "good"
    @message = "Positions Saved!"
    serve_json_response
    return    
  end

#### end testimonial stuff ####


  def logout
    current_user_session.destroy
    redirect_to admin_frontpage
  end  


  def as_admin_page
    if request.xhr?
      render :template => "admin/#{params[:action]}", :layout => false
    else  
      # set the hash to a sammy route
      redirect_to "/admin#/#{params[:action]}"
    end
  end



end
