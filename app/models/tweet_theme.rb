# Handles theme processing for tweet-based testimonials
# For notes see Theme model
class TweetTheme < Theme

  def self.names
    [
      "tweets",
      "custom"
    ]
  end
    
  # parse tweet tokens
  # For now, our js template is just a function call.
  # this changes valid tokens to js object value getters.
  def self.parse_tweet(data, tokens)
    data.gsub(/[\n\r\t]/,'').gsub("'","&#146;").gsub("+","&#43;").gsub(Token_regex) { |tkn|
      tokens.include?($1.to_sym) ? "'+item.#{$1.to_s.gsub("user_", "user.")}+'" : tkn
    }
  end


  def publish
    publish_css
    publish_tweet_bootstrap
  end

  def publish_css
    storage = Storage.new(self.user.apikey)
    storage.connect
    storage.add_tweet_theme_stylesheet(generate_css)
  end
  
  # HTML is packaged in the theme_config
  # This is for the standard theme
  def publish_tweet_bootstrap
    storage = Storage.new(self.user.apikey)
    storage.connect
    storage.add_tweet_bootstrap(generate_tweet_bootstrap)
  end
  
  def generate_css
    get_attribute("style.css").staged
  end
  
  
  # returns tweet_bootstrap file contents
  # see self.render_tweet_bootstrap for notes.
  def generate_tweet_bootstrap(for_staging=false)  
    TweetTheme.render_tweet_bootstrap(
      :user         => self.user,
      :stylesheet   => for_staging ? "" : self.theme_stylesheet_url,
      :wrapper      => self.get_attribute("tweet-wrapper.html").staged,
      :tweet        => self.get_attribute("tweet.html").staged
    )
  end
  
  # builds the tweet_bootstrap js file.
  # Note this is the main file users include on their site.
  # This file is responsible for bootstrapping the widget.
  # We push this to s3 and redirect to it from our api widget.js call
  def self.render_tweet_bootstrap(opts)
    context = ApplicationController.new
    opts[:user]         ||= nil
    opts[:stylesheet]   ||= ""
    opts[:wrapper]      ||= ""
    opts[:tweet]        ||= ""
    
    # parse wrapper.html for tokens 
    wrapper_tokens = {
      :count    => '<span class="pandA-tCount_ness"></span>',
      :tweets   => '<span class="pandA-tWrapper_ness"></span>',
    }
    wrapper = Theme.parse_wrapper(opts[:wrapper], wrapper_tokens)
    
    # parse tweet.html for tokens
    tokens = Tweet.api_attributes
    tweet = TweetTheme.parse_tweet(opts[:tweet], tokens)

    if Rails.env.development?
      widget_url = "/javascripts/widget/tweet.js"
    else  
      widget_url = Storage.new().tweet_widget_url
    end
    
    context.render_to_string(
      :partial => "widgets/tweet_bootstrap",
      :locals  => {
        :apikey         => opts[:user].apikey,
        :stylesheet     => opts[:stylesheet],
        :wrapper_html   => wrapper,
        :tweet_html     => tweet,
        :widget_url     => widget_url,
      }
    )
  end
  
  def theme_stylesheet_url
    Storage.new(self.user.apikey).tweet_theme_stylesheet_url
  end
  
end
