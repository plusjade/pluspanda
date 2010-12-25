module AdminHelper

  def collection_form_url
    "#{root_url.chomp('/')}#{new_testimonial_path}?apikey=#{@user.apikey}"
  end
  
end
