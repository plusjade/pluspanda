desc "Delete trashed testimonials"
task :empty_trash => :environment do
  puts "Starting..."

  testimonials = Testimonial.where("trash = ? AND updated_at < ?", true, DateTime.now - 7.days)
  puts "Trash Count: #{testimonials.count}"

  puts testimonials.delete_all ? "Trash Success!" : "Trash no good =("
end