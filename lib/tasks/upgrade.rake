# methods needed to upgrade old system to newer systems

desc "1) port old css and theme data to new database managed theme system"
task :upgrade_themes => :environment do
  "porting old themes to new"
  themes_path = Rails.root.join("public","themes")
  
  User.all.each do |user|
    next if user.tconfig.nil?
    theme = user.tconfig.theme
    next if theme.blank?
    next if Theme.names.index(theme).nil?

    #create new theme row, mark as staged
    user.themes.create(:name => Theme.names.index(theme), :staged => true)

    # update css with old filesystem css 
    css_path = Rails.root.join("public","system", "data", user.apikey, "#{theme}.css")
    old_css = File.exist?(css_path) ? File.new(css_path).read : "/*no file*/"
    
    # preserve old image formatting
    if theme == "list"
      old_css << "\n#pluspanda-testimonials div.image img { width:148px; height:148px;}\n"
    end
    
    css = user.get_attribute("style.css")
    css.update_attributes(:staged => old_css)

    puts user.apikey + " ported."
  end

end


=begin
  url("/images/common/widget/sm-rating.png")
    url('/_pAndAThemeS_/legacy/images/sm-rating.png')
  
  url('/images/common/load.gif')
    url('/_pAndAThemeS_/legacy/images/load.gif')
  
  url(/images/themes/list/panda_title_lft.png)
    url(/_pAndAThemeS_/list/images/show_more_bg.png)
  replace: /images/themes/list/ : /_pAndAThemeS_/list/images/
=end

desc "loop through all staged css and perform search and replace for urls"
task :grep_css => :environment do
  name = ThemeAttribute.names.index("style.css")
  puts ThemeAttribute.where(:name => name).count
  
  ThemeAttribute.where(:name => name).each do |a|
    css = a.staged.gsub("/images/themes/list/", "/_pAndAThemeS_/list/images/")
    css = css.gsub("/images/common/widget/", "/_pAndAThemeS_/legacy/images/")
    css = css.gsub("/images/common/", "/_pAndAThemeS_/legacy/images/")

    a.staged = css
    if a.save
      puts "saved css successfully."
    end
    
  end
  
end


desc "Explicitely publish all user staged themes."
task :publish_themes => :environment do
  puts "publishing..."
  
  User.all.each do |user|
    next if user.tconfig.nil?
    theme = user.tconfig.theme
    next if theme.blank?
    next if Theme.names.index(theme).nil?
    
    user.publish_theme
    puts "published " + user.apikey
  end
  
end
