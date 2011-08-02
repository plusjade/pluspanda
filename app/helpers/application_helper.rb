module ApplicationHelper

  def api_version_number
    "v1"
  end
  
  def embed_code(apikey)
    return "<script type=\"text/javascript\" src=\"#{widget_script_url}\" charset=\"utf-8\"></script>"
  end
  
  def widget_script_url
    return "#{root_url+widget_testimonials_path}.js?apikey=#{@user.apikey}"
  end

  def tweet_widget_script_url
    "#{root_url+widget_tweets_path}.js?apikey=#{@user.apikey}"
  end
  
  def root_url
    ::Rails.env == 'production' ? 'http://api.pluspanda.com' : 'http://localhost:3000'
  end
  
end
