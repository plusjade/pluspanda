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