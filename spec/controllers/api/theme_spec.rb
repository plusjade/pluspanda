require 'spec_helper'

describe Api::ThemeController do
  context "Unauthenticated" do
    it "original css should redirect to login screen" do
     get :publish, { id: 1 }

      response.response_code.should be 401
    end

    it "staged css should redirect to login screen" do
      get :create, { id: 1 }

      response.response_code.should be 401
    end
  end

  context "Authenticated user" do
    before(:each) do
      @user = create_and_authenticate_user
    end

    after(:each) do
      @user.destroy
    end

    it "should publish the staged theme and return success" do
     post :publish, {
       id: @user.id,
       format: "json"
     }

      response.should be_success
    end

    it "should 404 when theme not found" do
      get :create, {
        id: @user.id,
        theme: {
          name: "hai"
        },
        format: "json"
      }

      response.response_code.should be 404
    end

    it "return success when theme found" do
      get :create, {
        id: @user.id,
        theme: {
          name: Theme::Names.first
        },
        format: "json"
      }

      response.should be_success
    end
  end
end
