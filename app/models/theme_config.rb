module ThemeConfig
  # builds the theme_config js file.
  # Note this is the main file users include on their site.
  # This file is responsible for bootstrapping the widget.
  # We push this to s3 and redirect to it from our api widget.js call
  def self.render(opts)
    context = ApplicationController.new
    opts[:user]         ||= nil
    opts[:stylesheet]   ||= ""
    opts[:wrapper]      ||= ""
    opts[:testimonial]  ||= ""
    
    # parse wrapper.html for tokens
    tag_list = context.render_to_string(
      :partial  => "testimonials/tag_list",
      :locals   => { :tags => Tag.where({:user_id => opts[:user].id }) }
    ).gsub(/[\n\r\t]/,'')    
    wrapper_tokens = {
      :tag_list       => tag_list,
      :count          => '<span class="pandA-tCount_ness"></span>',
      :testimonials   => '<span class="pandA-tWrapper_ness"></span>',
      :form_link      => '<a href="#" class="pandA-addForm_ness">{{param}}</a>'
    }
    wrapper = ThemeParser.parse_wrapper(opts[:wrapper], wrapper_tokens)

    # parse testimonial.html for tokens
    tokens = Testimonial.api_attributes
    testimonial = ThemeParser.parse_testimonial(opts[:testimonial], tokens)

    context.render_to_string(
      :partial => "testimonials/theme_config",
      :locals  => {
        pandaSettings: {
          generationTime: Time.now,
          apiUrl: "//#{ Rails.application.routes.default_url_options[:host] }",
          apiVrsn: "v1",
          apikey: opts[:user].apikey,
          formEndpoint: "//#{ Rails.application.routes.default_url_options[:host] }/v1/testimonials/new.iframe?apikey=#{ opts[:user].apikey }",
          testimonialsEndpoint: "//#{ Rails.application.routes.default_url_options[:host] }/v1/testimonials.js"
        },
        :stylesheet         => opts[:stylesheet],
        :wrapper_html       => wrapper,
        :testimonial_html   => testimonial,
        :widget_url         => widget_url(opts[:theme_name])
      }
    )
  end

  # Hack, need a proper way to discern which themes need which widget bootstrap version.
  V2 = %w(modern)
  def self.widget_url(theme_name)
    version = (V2.include?(theme_name) ? 2 : 1)

    widget = Publish::WidgetJs.new(version: version)
    Rails.env.development? ?
      "/javascripts/widget/widget-v#{ version }.js" :
      widget.endpoint
  end
end
