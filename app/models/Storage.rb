require "aws/s3"
class Storage

  Url = "http://s3.amazonaws.com/"
  Stylesheet_filename = "data/{{apikey}}/style.css"
  Theme_config_filename = "data/{{apikey}}/theme_config.js"

  def self.bucket
    credentials = YAML::load(File.open("#{Rails.root.to_s}/config/s3.yml"))[Rails.env]
    credentials["bucket"]
  end
    
  def initialize(user)
    credentials = YAML::load(File.open("#{Rails.root.to_s}/config/s3.yml"))[Rails.env]
    @access_key_id = credentials["access_key_id"]
    @secret_access_key = credentials["secret_access_key"]
    @bucket = credentials["bucket"]
    @apikey = user.apikey
  end
  
  def connect
    AWS::S3::Base.establish_connection!({
      :access_key_id      => @access_key_id, 
      :secret_access_key  => @secret_access_key
    })
  end

  def store(filename, filepath)
    AWS::S3::S3Object.store(filename, open(filepath), @bucket)
  end
    
  
  def add_stylesheet(data)
    f = File.new(tmp_stylesheet_path, "w+")
    f.write(data)
    f.rewind
    store(stylesheet_filename, tmp_stylesheet_path)
  end
  
  def add_theme_config(data)
    f = File.new(tmp_theme_config_path, "w+")
    f.write(data)
    f.rewind
    store(theme_config_filename, tmp_theme_config_path)
  end
  
  
  def stylesheet_filename
    Stylesheet_filename.gsub("{{apikey}}", @apikey)
  end
  
  def theme_config_filename
    Theme_config_filename.gsub("{{apikey}}", @apikey)
  end
  
  
  # the published stylesheet is NOT theme specific.
  def stylesheet_url
    url(Stylesheet_filename.gsub("{{apikey}}", @apikey))
  end 

  def theme_config_url
    url(Theme_config_filename.gsub("{{apikey}}", @apikey))
  end
  
  def url(path=nil)
    path ? "#{Url}#{@bucket}/#{path}" : "#{Url}#{@bucket}"
  end
  
  
  def tmp_stylesheet_path
    Rails.root.join("tmp", "#{@apikey}.css")
  end

  def tmp_theme_config_path
    Rails.root.join("tmp", "#{@apikey}.js")
  end 

end