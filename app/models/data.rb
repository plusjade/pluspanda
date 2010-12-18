class Data < ActiveRecord::Base



  def settings_file_path
    return data_path('settings.js')
  end 

  # the current theme's staging css
  def theme_css_path 
    return data_path("#{self.tconfig.theme}.css")
  end

  # the published css. This is NOT theme specific.
  def publish_css_path 
    return data_path("publish.css")
  end
  
  # the current theme's stock css
  def theme_stock_css_path 
    return Rails.root.join('public','themes',self.tconfig.theme, "#{self.tconfig.theme}.css")
  end  

  
  def data_path(path=nil)
    return (path.nil?) ? File.join(ensure_path) : File.join(ensure_path, path)
  end
   
  private      
  
    def ensure_path
      path = Rails.root.join('public','system', 'data', self.apikey)
      FileUtils.mkdir_p(path) if !File.directory?(path)
      return path
    end
  
    
end
