module ApplicationHelper
  def api_version_number
    "v1"
  end

  def embed_code(apikey)
    "<script type='text/javascript'>(function() {
        var s = document.createElement('script'); s.type = 'text/javascript'; s.async = true;
        s.src = '#{ Rails.application.routes.url_helpers.widget_testimonials_url(format: 'js', apikey: apikey) }';
        document.body.appendChild(s);
    })();</script>"
  end
end
