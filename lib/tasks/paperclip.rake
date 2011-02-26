
# First configure your models to use Amazon s3 as storage option and setup the associated S3 config.
# Then add the classes your want to migrate in the klasses array below.
# Then run rake paperclip_migration:migrate_to_s3
# Should work but this is untested and may need some tweaking - but it did the job for me.

namespace :paperclip_migration do  
  desc "migrate files from filesystem to s3"
  task :migrate_to_s3 => :environment do
    klasses = [:Testimonial] # Replace with your real model names. If anyone wants to this could be picked up from args or from configuration.
    klasses.each do |klass_key|
      if klass = real_klass(klass_key)
        if klass.respond_to?(:attachment_definitions) && definitions = klass.attachment_definitions
          
          
          klass.all.each do |record|
            
            definitions.keys.each do |definition|
              if record.send("#{definition}_file_name")
                
                attachment = Paperclip::Attachment.new(definition.to_sym, record, definitions[definition.to_sym].except(:s3_credentials, :storage))
                if File.exists?(Rails.root.to_s + "/public" + attachment.url)
                  file_data =  File.open(Rails.root.to_s + "/public" + attachment.url)
                  puts "Saving file: #{Rails.root.to_s + "/public" + attachment.url} to Amazon S3..."
                  record.send("#{definition}").assign file_data
                  record.send("#{definition}").save
                else
                  puts "Can't find file: #{Rails.root.to_s + "/public" + attachment.url} NOT MIGRATING..."
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
  end
  
  def real_klass(key)
    key.to_s.classify.constantize
  rescue
  end
end