module Publish
  class Stylesheet
    FilenameFormat = "data/{{apikey}}/style-{{digest}}.css"

    def initialize(apikey, content)
      @apikey = apikey
      @content = content
    end

    def endpoint
      Storage.url(filename)
    end

    def digest
      return @digest if @digest
      f = File.new(tmp, "w+")
      f.write(@content)
      f.rewind

      Digest::MD5.file(tmp).hexdigest
    end

    def publish
      Storage.store(filename, tmp, content_type: "text/css")
    end

    def filename
      FilenameFormat
        .gsub("{{apikey}}", @apikey)
        .gsub("{{digest}}", digest)
    end

    def tmp
      Rails.root.join("tmp", "#{ @apikey }.css")
    end
  end

  class Config
    FilenameFormat = "data/{{apikey}}/theme_config.js"

    def initialize(apikey, content)
      @apikey = apikey
      @content = content
    end

    # the published stylesheet is NOT theme specific.
    def endpoint
      Storage.url(filename)
    end

    # HTML is packaged in the theme_config
    # This is for the standard theme
    def publish
      f = File.new(tmp, "w+")
      f.write(@content)
      f.rewind

      Storage.store(filename, tmp, content_type: "text/javascript")
    end

    def tmp
      Rails.root.join("tmp", "#{ @apikey }.js")
    end

    def filename
      FilenameFormat.gsub("{{apikey}}", @apikey)
    end
  end
end
