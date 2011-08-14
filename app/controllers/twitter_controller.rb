class TwitterController < ApplicationController

  layout proc { |c| c.request.xhr? ? false : "admin"}
  before_filter :require_user, :setup_user

  # this is so we are always loading admin pages through sammy.js
  before_filter :as_admin_page, :only => [:widget, :manage, :install, :collect]

  
  def index

  end

  def widget

  end

  def manage
    @tweets = @user.tweets.where(:trash => false).order("position ASC, created_at DESC")
  end

  def install  

  end

  def staged
    @theme = @user.tweet_themes.get_staged
    @css = @theme.get_attribute("style.css").staged
    @theme_config = @theme.generate_tweet_bootstrap(true)

    render :template => "twitter/staged", :layout => "twitter_staged"
  end

  def published
    render :template => "twitter/published", :layout => "twitter_published"
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



  def as_admin_page
    @theme = @user.tweet_themes.get_staged
    @tweets = @user.tweets.where(:trash => false).order("position ASC, created_at DESC")
    
    if request.xhr?
      render :template => "twitter/#{params[:action]}", :layout => false
    else  
      # set the hash to a sammy route
      redirect_to "/admin/twitter#/t_#{params[:action]}"
    end
  end



end
