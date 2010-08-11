module ApplicationHelper

  def embed_code(apikey, jquery=true)
    jquery = (jquery) ? '' : '&jquery=false'
    code = "<div id=\"plusPandaYes\"></div><script type=\"text/javascript\" src=\"#{root_url}testimonials/widget.js?apikey=#{apikey}#{jquery}\" charset=\"utf-8\"></script>"
    return code 
  end

end
