require 'spec_helper'

describe AdminController do
  describe "when no user is authenticated" do
    it "admin should redirect to login screen" do
      get :index

      response.should redirect_to new_session_path
    end
  end

  describe "when a user is authenticated" do  
    before(:each) do
      @user = create_and_authenticate_user
    end

    after(:each) do
      @user.destroy
    end

    it "logged in admin should be success" do
      get :index

      response.should be_success
    end
  end
end
