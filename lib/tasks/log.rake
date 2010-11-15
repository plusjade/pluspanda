
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
  
desc "update loggging strategy"
task :update_logs => :environment do 
  puts "Starting..."
  
  counts = {}
  urls = {}
  WidgetLog.all.each do |row|
    if counts[row.user_id]
      counts[row.user_id] += 1
    else
      counts[row.user_id] = 1
    end
    urls[row.user_id] = row.url
    
    row.destroy
  end
  
  counts.each_pair do |k,v|
    log = WidgetLog.new
    log.user_id = k
    log.impressions = v
    log.url = urls[k]
    log.save
  end
  
end

  
desc "Dump Widget logs to Mysql"
task :dump_widget_logs => :environment do 
  puts "Starting..."
  log_file = Rails.root.join('log', 'widget.log')
  break unless File.exist?(log_file)

  counts = {}
  urls = {}
  FasterCSV.foreach(log_file) do |row|
    apikey  = row[0]
    url     = row[1]
    date    = row[2]

    if counts[apikey]
      counts[apikey] += 1
    else
      counts[apikey] = 1
    end
    
    urls[apikey] = url
  end

  counts.each_pair do |k,v|
    user    = User.find_by_apikey(k)
    next if user.nil?
    
    log = WidgetLog.find_by_user_id(user.id)
    if log.nil?
      log = WidgetLog.new
      log.user_id = user.id
    end
    log.impressions += v
    log.url = urls[k]
    log.save
  end
  
      
  File.open(log_file, 'w+') { |f| f.write('') }
  puts "Done!"
end