credentials = YAML::load(File.open("#{Rails.root.to_s}/config/s3.yml"))[Rails.env]
Storage.handle = AWS::S3.new(
  :access_key_id => credentials["access_key_id"],
  :secret_access_key => credentials["secret_access_key"])

Storage.bucket_name = credentials['bucket']