module ApplicationHelper

  def api_version_number
    "v1"
  end

  def embed_code(apikey)
    "<script type=\"text/javascript\">document.write(unescape(\"%3Cscript src='#{widget_script_url}' type='text/javascript'%3E%3C/script%3E\"));</script>"
  end

  def widget_script_url
    "#{root_url+widget_testimonials_path}.js?apikey=#{@user.apikey}"
  end

  def root_url
    ::Rails.env == 'production' ? 'http://api.pluspanda.com' : 'http://localhost:3000'
  end
  
end
