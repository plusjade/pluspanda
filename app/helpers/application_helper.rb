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

  def root_url
    ::Rails.env == 'production' ? 'http://api.pluspanda.com' : 'http://localhost:3000'
  end
  
  
  def bundled_javascripts
    javascript_path = Rails.root.join('public', 'javascripts')
    bundle = []
    
    # 3rd party libraries should load first...
    Dir["#{javascript_path}/bundle/lib/*.js"].each do |script| 
      bundle.push("bundle/lib/#{File.basename(script)}")
    end
    
    # then our libraries...    
    Dir["#{javascript_path}/bundle/*.js"].each do |script| 
      bundle.push("bundle/#{File.basename(script)}")
    end
    
    # add the global pages javascript to the bundle last.
    global_js = "#{javascript_path}/pages/_global.js"
    if File.exist?(global_js)
      bundle.push("pages/_global.js")
    end  
    
    bundle
  end
  
  
end
