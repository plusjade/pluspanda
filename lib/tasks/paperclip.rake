
# First configure your models to use Amazon s3 as storage option and setup the associated S3 config.
# Then add the classes your want to migrate in the klasses array below.
# Then run rake paperclip_migration:migrate_to_s3
# Should work but this is untested and may need some tweaking - but it did the job for me.

desc "test migrate"
task :test_migrate => :environment do
  limit = 2
  counter = 0
  base_path = Rails.root.join("public", "system").to_s
  base_path = "/var/www/pluspanda/production/shared/system"
  definitions = Testimonial.attachment_definitions
  
  Testimonial.all.each do |record|
    definitions.keys.each do |definition|
      unless record.send("#{definition}_file_name").blank?
        attachment = Paperclip::Attachment.new(definition.to_sym, record, definitions[definition.to_sym].except(:s3_credentials, :storage))
        path = base_path + attachment.url
        
        if File.exists?(path)
          puts "Saving file: #{path} to Amazon S3..."
          record.send(definition).assign File.open(path)
          record.send(definition).save
          counter += 1
        else
          puts "Can't find file: #{path} NOT MIGRATING..."
        end
      end
    end
  
    break if counter == limit
  end

  exit
end

namespace :paperclip_migration do  
  desc "migrate files from filesystem to s3"
  task :migrate_to_s3 => :environment do
    klasses = [:Testimonial] # Replace with your real model names. If anyone wants to this could be picked up from args or from configuration.
    path = "/var/www/pluspanda/production/shared"
    klasses.each do |klass_key|
      if klass = real_klass(klass_key)
        if klass.respond_to?(:attachment_definitions) && definitions = klass.attachment_definitions
          klass.all.each do |record|
            definitions.keys.each do |definition|
              if record.send("#{definition}_file_name")
                attachment = Paperclip::Attachment.new(definition.to_sym, record, definitions[definition.to_sym].except(:s3_credentials, :storage))
                
                if File.exists?(path + attachment.url)
                  file_data =  File.open(path + attachment.url)
                  puts "Saving file: #{path + attachment.url} to Amazon S3..."
                  record.send("#{definition}").assign file_data
                  record.send("#{definition}").save
                else
                  puts "Can't find file: #{path + attachment.url} NOT MIGRATING..."
                end
                
                if File.exists?(path + attachment.url(:sm))
                  file_data =  File.open(path + attachment.url(:sm))
                  puts "Saving file: #{path + attachment.url(:sm)} to Amazon S3..."
                  record.send("#{definition}").assign file_data
                  record.send("#{definition}").save
                else
                  puts "Can't find file: #{path + attachment.url(:sm)} NOT MIGRATING..."
                end
                
              end
            end
          end
        else
          puts "There are not paperclip attachments defined for the class #{klass.to_s}"
        end
      else
        puts "#{key.to_s.classify} is not defined in this app."
      end
    end
    break
  end
  
  def real_klass(key)
    key.to_s.classify.constantize
  rescue
  end
  
end