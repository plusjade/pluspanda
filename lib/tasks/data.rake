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
end