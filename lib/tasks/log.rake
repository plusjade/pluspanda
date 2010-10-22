
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