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