desc "re-save theme HTML to user theme-attribute original field"
task :update_theme_attributes => :environment do
  puts "updating attributes"

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
