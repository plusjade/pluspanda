module ApplicationHelper

  def embed_code(apikey, jquery=true)
    jquery = (jquery) ? '' : '&jquery=false'
    return "<div id=\"plusPandaYes\"></div><script type=\"text/javascript\" src=\"#{widget_script_url}#{jquery}\" charset=\"utf-8\"></script>"
  end
  
  def widget_script_url
    return "#{root_url}testimonials/widget.js?apikey=#{@user.apikey}"
  end

  def root_url
    if RAILS_ENV=='production'
      return "http://api.pluspanda.com/"
    else
      return "http://localhost:3000/"
    end
  end
  
end
