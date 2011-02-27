
namespace :s3 do  

  desc "themes to s3"
  task :export_themes => :environment do
    require "aws/s3"
    credentials = YAML::load(File.open("#{Rails.root.to_s}/config/s3.yml"))["production"]
    s3_theme_folder = "themes"

    AWS::S3::Base.establish_connection!({
      :access_key_id      => credentials["access_key_id"], 
      :secret_access_key  => credentials["secret_access_key"]
    })

    root = Theme::Themes_path
    # all themes.
    Dir.new(root).each do |theme|
      next if theme.index(".") == 0 || theme == "Thumbs.db"
      theme_path = root + theme
      
      # each theme.
      Dir.new(theme_path).each do |theme_asset|
        next if theme_asset.index(".") == 0
        theme_asset_path = theme_path + theme_asset
        
        # theme image directory.
        if File.directory?(theme_asset_path)

          Dir.new(theme_asset_path).each do |image|
            next if image.index(".") == 0 || image == "Thumbs.db"
            image_path = theme_asset_path + image
            
            filename = image_path.to_s.gsub("#{root}", s3_theme_folder)
            
            puts AWS::S3::S3Object.store(filename, open(image_path), credentials["bucket"])
          end
        
        # theme assets.
        elsif File.exist?(theme_asset_path)
          next if theme_asset_path == "Thumbs.db"
          
          filename = theme_asset_path.to_s.gsub("#{root}", s3_theme_folder)
          
          puts AWS::S3::S3Object.store(filename, open(theme_asset_path), credentials["bucket"])  
        end
      end
    end  
    exit
  end

  
  
end