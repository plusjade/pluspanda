require Rails.root.join("app","helpers","application_helper")
include ApplicationHelper

desc "build a bundled javascript file"
task :bundle_js => :environment do
  puts "Bundling..."
  
  javascript_path = Rails.root.join('public', 'javascripts')
  bundle = File.join(javascript_path, 'bundle.js')

  # TODO: we should also minify this.
  File.open(bundle, "w+") do |bundle|
    bundled_javascripts.each do |script|
      script = File.join(javascript_path, script)
      puts "Adding: #{File.basename(script)}"
      bundle << File.open(script, "r").read + "\n"
    end
  end
  
  puts "done!"
    
end

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