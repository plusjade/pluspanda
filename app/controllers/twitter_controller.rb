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
    @tweets = @user.tweets.where(:trash => false).order("position ASC, created_at DESC")
  end

  def install  

  end

  def staged
    @css = @user.get_attribute("style.css").staged

    @theme_config = @user.generate_theme_config(true)

    render :template => "twitter/staged", :layout => "staged"
  end

  def published
    render :template => "twitter/published", :layout => "published"
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



  def as_admin_page
    if request.xhr?
      render :template => "admin/#{params[:action]}", :layout => false
    else  
      # set the hash to a sammy route
      redirect_to "/admin#/#{params[:action]}"
    end
  end



end
