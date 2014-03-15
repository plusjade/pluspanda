module Publish
  class Stylesheet
    FilenameFormat = "data/{{apikey}}/style.css"

    def initialize(apikey)
      @apikey = apikey
    end

    def endpoint
      Storage.url(filename)
    end

    def publish(content)
      f = File.new(tmp, "w+")
      f.write(content)
      f.rewind

      Storage.store(filename, tmp, content_type: "text/css")
    end

    def tmp
      Rails.root.join("tmp", "#{ @apikey }.css")
    end

    def filename
      FilenameFormat.gsub("{{apikey}}", @apikey)
    end
  end

  class Config
    FilenameFormat = "data/{{apikey}}/theme_config.js"

    def initialize(apikey)
      @apikey = apikey
    end

    # the published stylesheet is NOT theme specific.
    def endpoint
      Storage.url(filename)
    end

    # HTML is packaged in the theme_config
    # This is for the standard theme
    def publish(content)
      f = File.new(tmp, "w+")
      f.write(content)
      f.rewind

      Storage.store(filename, tmp)
    end

    def tmp
      Rails.root.join("tmp", "#{ @apikey }.js")
    end

    def filename
      FilenameFormat.gsub("{{apikey}}", @apikey)
    end
  end
end
