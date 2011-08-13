desc "re-save theme HTML to user theme-attribute original field"
task :update_theme_attributes => :environment do
  puts "updating attributes"

end

desc "loop through all staged css and perform search and replace for urls"
task :grep_css => :environment do
  name = ThemeAttribute.names.index("style.css")
  puts ThemeAttribute.where(:name => name).count
  
  ThemeAttribute.where(:name => name).each do |a|
    css = a.staged.gsub("/_pAndAThemeS_", "http://s3.amazonaws.com/pluspanda/themes")
    a.staged = css
    if a.save
      puts "saved css successfully."
    end
    
  end
  
end

desc "Explicitely publish all user staged themes."
task :publish_standard_themes => :environment do
  puts "publishing..."
  
  User.all.each do |user|
    if user.themes.find_by_staged(true)
      user.publish_standard_theme
    end
    puts "published " + user.apikey
  end
  
end
