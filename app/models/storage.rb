# This interfaces with amazon s3 to physically store files.
class Storage
  Url = "http://s3.amazonaws.com/"

  class << self
    attr_accessor :handle, :bucket_name

    def bucket
      handle.buckets[bucket_name]
    end

    # save/update a file to s3
    def store(key, filepath)
      bucket.objects[key].write(filepath)
    end

    # returns the absolute url path to our s3 bucket
    def url(path=nil)
      path ? "#{Url}#{bucket_name}/#{path}" : "#{Url}#{bucket_name}"
    end

    # This is the s3 path to the static standard-widget-js-bootstrapper
    def standard_widget_url
      url("javascripts/widget/widget.js")
    end
  
    # static s3 path to facebox.js  
    def facebox_url
      url("javascripts/widget/facebox.js")
    end
  end
end