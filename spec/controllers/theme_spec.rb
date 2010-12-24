require 'spec_helper'

describe ThemeController do
  
  def mock_user_session(stubs={})
    @mock_user_session ||= mock_model(UserSession, stubs).as_null_object
  end

  describe "when no user is authenticated" do

    it "stock_css should redirect to login screen" do
      get :original, :attribute => "wrapper-html"
      
      response.should redirect_to new_account_path
    end
       
    it "css should redirect to login screen" do
      get :staged, :attribute => "wrapper-html"
      
      response.should redirect_to new_account_path
    end
 
  end
 
  
  describe "when a user is authenticated" do  
    
    before(:each) do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user 
    end
          
    after(:each) do
      @user.destroy
    end
    
    it "should upate css" do

      post :update, :attribute => "wrapper-html", :data => "some css stuff"

      response.should be_success
    end
 
 end

end