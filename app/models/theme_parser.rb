module ThemeParser
  # matches {{blah_token}}, {{blah_token:param}}
  Token_regex = /\{{2}(\w+):?([\w\s?!:"',\.]*)\}{2}/i

  # parses the theme wrapper attribute
  def self.parse_wrapper(data, tokens)
    data.gsub(/[\n\r\t]/,'').gsub("'","&#146;").gsub("+","&#43;").gsub(Token_regex) do |tkn|
      tokens.has_key?($1.to_sym) ? tokens[$1.to_sym].gsub("{{param}}", $2) : tkn
    end
  end

  def self.parse_testimonial(data, tokens)
    data.gsub(/[\n\r\t]/,'').gsub("'","&#146;").gsub("+","&#43;").gsub(Token_regex) do |tkn|
      tokens.include?($1.to_sym) ? "'+item.#{$1.to_s}+'" : tkn
    end
  end
end
