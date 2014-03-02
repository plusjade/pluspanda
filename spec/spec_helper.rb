require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

module AppHelpers
  def create_user
    # TODO refine implementation and expectations
    stub_request(:put, /https:\/\/s3.amazonaws.com\/pluspanda_development\/data\/.+\/.+/)

    FactoryGirl.create(:user)
  end

  def create_and_authenticate_user
    activate_authlogic

    user = create_user
    UserSession.create(user)
    user
  end
end

Spork.prefork do

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'

  require "cancan/matchers"
  require 'webmock/rspec'
  require "authlogic/test_case"
  include Authlogic::TestCase 
  include AppHelpers

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  RSpec.configure do |config|
    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = "random"
  end

end

Spork.each_run do
  # This code will be run each time you run your specs.
  FactoryGirl.reload
end
