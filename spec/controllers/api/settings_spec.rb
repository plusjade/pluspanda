require 'spec_helper'

describe Api::SettingsController do
  context "Unauthenticated" do
    it "original css should redirect to login screen" do
     get :update, { id: 1 }

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

    it "should return success" do
     put :update, {
       id: @user.id,
       "tconfig"=> { "per_page"=>"1", "sort"=>"created" },
       format: "json"
     }

      response.should be_success
    end
  end
end
