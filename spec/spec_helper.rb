# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.

ENV["RAILS_ENV"] = 'test'

require File.dirname(__FILE__) + "/../config/environment"
require 'rspec/rails'
require 'rspec/expectations'
require 'webrat'
require "authlogic/test_case"
require 'factory_girl'
Dir["#{File.dirname(__FILE__)}/factories/*.rb"].each {|f| require f}

include Authlogic::TestCase 


Webrat.configure do |config|
  config.mode = :rails
end

Rspec.configure do |config|
  require 'rspec/expectations'
  config.include Rspec::Matchers
  config.mock_with :rspec
end

class Class
  def publicize_methods
    saved_private_instance_methods = self.private_instance_methods
    self.class_eval { public *saved_private_instance_methods }
    yield
    self.class_eval { private *saved_private_instance_methods }
  end
end


def current_user(stubs = {})
  @current_user ||= mock_model(User, stubs)
end

def user_session(stubs = {}, user_stubs = {})
  @current_user_session ||= mock_model(UserSession, {:user => current_user(user_stubs)}.merge(stubs))
end

def login(session_stubs = {}, user_stubs = {})
  UserSession.stub!(:find).and_return(user_session(session_stubs, user_stubs))
end

def logout
  @user_session = nil
end





def login_user(options = {})
   @logged_in_user = Factory.create(:user2, options)
   @controller.stub!(:current_user).and_return(@logged_in_user)
   @logged_in_user
 end
 
 def login_admin(options = {})
   options[:admin] = true
   @logged_in_user = Factory.create(:user2, options)
   @controller.stub!(:current_user).and_return(@logged_in_user)
   @logged_in_user
 end
 
 def logout_user
   @logged_in_user = nil
   @controller.stub!(:current_user).and_return(@logged_in_user)
   @logged_in_user
 end