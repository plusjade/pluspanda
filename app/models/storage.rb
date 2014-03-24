# This interfaces with amazon s3 to physically store files.
class Storage
  Credentials = YAML::load(File.open(Rails.root.join('config', 's3.yml')))[Rails.env]
  Url = "//s3.amazonaws.com/"
  raise "S3 storage credentials not found" unless Credentials

  class << self
    attr_accessor :handle, :bucket_name

    def handle
      @handle ||= AWS::S3.new({
        access_key_id: Credentials["access_key_id"],
        secret_access_key: Credentials["secret_access_key"]
      })
    end

    def bucket
      handle.buckets[bucket_name]
    end

    def bucket_name
      Credentials['bucket']
    end

    # save/update a file to s3
    def store(key, filepath, opts={})
      bucket.objects[key].write(filepath, opts)
    end

    # returns the absolute url path to our s3 bucket
    def url(path=nil)
      path ? "#{Url}#{bucket_name}/#{path}" : "#{Url}#{bucket_name}"
    end
  end
end
