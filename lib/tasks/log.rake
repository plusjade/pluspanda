
desc "Update all sass stylesheets to production css"
task :sassify, [:file] => :environment do |t, args|
  puts "starting..."
  layouts_path      = Rails.root.join('app','views','layouts')
  stylesheets_path  = Rails.root.join('public','stylesheets')
  
  if args[:file]
    puts 'Running only => ' + args[:file]
    sass_path = File.join(layouts_path, args[:file] + ".sass")
    css_path  = File.join(stylesheets_path, args[:file] + '.css')
    sass_to_css(sass_path, css_path)
    puts 'done'
    next
  end
  
  Dir.foreach(layouts_path) do |file|
    next unless file =~ /.sass/
    puts file
    sass_path = File.join(layouts_path, file)
    css_path  = File.join(stylesheets_path, file.gsub!('.sass','.css'))
    sass_to_css(sass_path, css_path)
  end

end

def sass_to_css(sass_path, css_path)
  puts `sass #{sass_path} #{css_path} `
end
  
  
desc "Dump Widget logs to Mysql"
task :dump_widget_logs => :environment do 
  puts "Starting..."
  log_file = Rails.root.join('log', 'widget.log')
  break unless File.exist?(log_file)

  FasterCSV.foreach(log_file) do |row|
    apikey  = row[0]
    url     = row[1]
    date    = row[2]
    user    = User.find_by_apikey(apikey)
    next if user.nil?
    
    log = WidgetLog.new
    log.user_id     = user.id
    log.url         = url
    log.created_at  = date
    log.save
  end
  
  File.open(log_file, 'w+') { |f| f.write('') }
  puts "Done!"
end