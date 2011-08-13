# This interfaces with amazon s3 to physically store files.
require "aws/s3"
class Storage

  Url = "http://s3.amazonaws.com/"
  StandardThemeStylesheetFilename = "data/{{apikey}}/style.css"
  ThemeConfigFilename = "data/{{apikey}}/theme_config.js"

# interface to s3
# ===============

  def self.bucket
    credentials = YAML::load(File.open("#{Rails.root.to_s}/config/s3.yml"))[Rails.env]
    credentials["bucket"]
  end
    
  def initialize(apikey=nil)
    credentials = YAML::load(File.open("#{Rails.root.to_s}/config/s3.yml"))[Rails.env]
    @access_key_id = credentials["access_key_id"]
    @secret_access_key = credentials["secret_access_key"]
    @bucket = credentials["bucket"]
    @apikey = apikey.to_s
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
    
# Adders
# ===========
#   publishing necessarily means "save to s3"
#   These methods save theme files as noted.
  
  def add_standard_theme_stylesheet(data)
    f = File.new(tmp_stylesheet_path, "w+")
    f.write(data)
    f.rewind
    store(standard_theme_stylesheet_filename, tmp_stylesheet_path)
  end

  def add_theme_config(data)
    f = File.new(tmp_theme_config_path, "w+")
    f.write(data)
    f.rewind
    store(theme_config_filename, tmp_theme_config_path)
  end

    
# File names
# ===========
  
  
  def standard_theme_stylesheet_filename
    StandardThemeStylesheetFilename.gsub("{{apikey}}", @apikey)
  end
  
  def theme_config_filename
    ThemeConfigFilename.gsub("{{apikey}}", @apikey)
  end
  
  # the published stylesheet is NOT theme specific.
  def standard_theme_stylesheet_url
    url(StandardThemeStylesheetFilename.gsub("{{apikey}}", @apikey))
  end 

  def theme_config_url
    url(ThemeConfigFilename.gsub("{{apikey}}", @apikey))
  end
  
  def url(path=nil)
    path ? "#{Url}#{@bucket}/#{path}" : "#{Url}#{@bucket}"
  end

  # This is the s3 path to the static standard-widget-js-bootstrapper
  def standard_widget_url
    url("javascripts/widget/widget.js")
  end
  
  # This is the s3 path to the static tweet-widget-js-bootstrapper
  def tweet_widget_url
    url("javascripts/widget/widget.js")
  end
  
  # static s3 path to facebox.js  
  def facebox_url
    url("javascripts/widget/facebox.js")
  end
  
  def tmp_stylesheet_path
    Rails.root.join("tmp", "#{@apikey}.css")
  end

  def tmp_theme_config_path
    Rails.root.join("tmp", "#{@apikey}.js")
  end 

end