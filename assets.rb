require 'sprockets'
require 'uglifier'
class Uglifier
  class << self
    alias_method :compress, :compile
  end
end

env = Sprockets::Environment.new
#env.css_compressor = :sass
env.js_compressor  = Uglifier
env.logger = Logger.new(STDOUT)
env.logger.level = Logger::WARN

env.append_path('public/javascripts')
env.append_path('public/stylesheets')

manifest = Sprockets::Manifest.new(env, 'public/javascripts', 'public/stylesheets')
manifest.compile('application.js')
manifest.compile('application.css')

