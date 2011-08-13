# This interfaces with amazon s3 to physically store files.
require "aws/s3"
class Storage

  Url = "http://s3.amazonaws.com/"
  
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

  # save/update a file to s3
  def store(filename, filepath)
    AWS::S3::S3Object.store(filename, open(filepath), @bucket)
  end
    
  # returns the absolute url path to our s3 bucket
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

end