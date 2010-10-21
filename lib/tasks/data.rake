namespace :data do
  desc 'Clear all user settings.js files so they can regenerate'
  task :clear_settings do
    
    require 'fileutils'
    data = Rails.root.join('public', 'system', 'data')
    puts "\nClearing all user settings.js files...\n"
    puts '------------------------------------------'
    
    Dir.new(data).each do |api|
      next if api.index('.') == 0
      Dir.new(File.join(data, api)).each do |file|
        next if file != "settings.js"
        settings = File.join(data,api,file)
        FileUtils.rm(settings)
        puts "* removed: " +  settings
      end
    end

  end
  
  desc "Regen user setting.js files."
  task :regen_settings => :environment do
    puts "Starting..."
    x = 0
    User.all.each do |user|
      next if user.tconfig.theme.nil? || user.tconfig.theme.empty?
      user.update_settings
      x += 1
    end
    puts "Finished!"
    puts x.to_s + " users"
  end
end