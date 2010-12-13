require 'spec_helper'

describe AdminController do

  before(:all) do
    #@controller = AdminController.new
  end
  
  def mock_user_session(stubs={})
    @mock_user_session ||= mock_model(UserSession, stubs).as_null_object
  end

  describe "when no user is authenticated" do

    it "admin should redirect to login screen" do
      get :index
      
      response.should redirect_to new_account_path
    end
       
    it "widget should redirect to login screen" do
      get :widget
      
      response.should redirect_to new_account_path
    end
    
    it "manage should redirect to login screen" do
      get :manage
      
      response.should redirect_to new_account_path
    end
    
    it "intall should redirect to login screen" do
      get :install
      
      response.should redirect_to new_account_path
    end
    
    it "collect should redirect to login screen" do
      get :collect
      
      response.should redirect_to new_account_path
    end
    
    it "staging should redirect to login screen" do
      get :staging
      
      response.should redirect_to new_account_path
    end
    
    it "settings should redirect to login screen" do
      put :settings
      
      response.should redirect_to new_account_path
    end
        
    describe "testimonial functions" do    

      it "testimonials should redirect to login screen" do
        get :testimonials
      
        response.should redirect_to new_account_path
      end
    
      it "update should redirect to login screen" do
        get :update
      
        response.should redirect_to new_account_path
      end
    
      it "save_positions should redirect to login screen" do
        get :save_positions
      
        response.should redirect_to new_account_path
      end    
    
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
    
    it "logged in admin should be success" do

      get :index

      response.should be_success
    end
    
    it "should update settings" do
      theme = "legacy"
      per_page = 123
      
      put :settings, :tconfig => {:theme => theme, :per_page => per_page }

      @user.tconfig.reload
      @user.tconfig.theme.should == theme
      @user.tconfig.per_page.should == per_page

    end
    
    describe "testimonial functions" do

      it "should mass update testimonials" do  
        ids = []
        @user.testimonials.each do |t|
          ids.push(t.id)
          t.publish = false
          t.save
        end
                
        get :update, :do => "publish", :id => ids
        
        @user.testimonials.reload
        @user.testimonials.each do |t|
          t.publish.should == true
        end
      end
      
      it "should update testimonial positions" do
        ids = []
        @user.testimonials.map {|t| ids.push(t.id)}

        get :save_positions, :tstml => ids
        
        @user.testimonials.reload.each_with_index do |t, i|
          t.position.should == i
        end
      end

      
    end
    
  end


end