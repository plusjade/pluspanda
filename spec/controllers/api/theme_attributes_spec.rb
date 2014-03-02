require 'spec_helper'

describe Api::ThemeAttributesController do
  context "Unauthenticated" do
    it "original css should redirect to login screen" do
     get :original, {
       id: 1,
       attribute: "style.css",
       format: "json"
     }

      response.response_code.should be 401
    end

    it "staged css should redirect to login screen" do
      get :staged, {
        id: 1,
        attribute: "style.css",
        format: "json"
      }

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

    it "should upate css" do
      put :update, {
        id: @user.id,
        attribute: "wrapper.html",
        data: "some css stuff",
        format: "json"
      }

      response.should be_success
    end
 end
end