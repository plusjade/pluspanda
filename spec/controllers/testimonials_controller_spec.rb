require 'time'
require 'spec_helper'

describe TestimonialsController do
  context "Valid apikey" do
    before(:each) do
      @user = create_and_authenticate_user
    end

    after(:each) do
      @user.destroy
    end

    context "default" do
      it "should get default testimonials" do
        get :index, {
          apikey: @user.apikey,
          format: "json"
        }

        response.should be_success
        data = MultiJson.decode(response.body)

        # 3 seed testimonials by default
        data["update_data"]["total"].should == 3
        data["testimonials"].count.should == 3
      end
    end

    context "Sort by newest" do
      it "should get default testimonials in reverse chronological order" do

        # Make sure one testimonial is older than the other.
        testimonial = @user.testimonials.first
        testimonial.created_at = Time.now - 2.days
        testimonial.save

        get :index, {
          apikey: @user.apikey,
          sort: "newest",
          format: "json"
        }

        response.should be_success
        data = MultiJson.decode(response.body)

        created_at = data["testimonials"].map{ |a| Time.parse(a["created_at"]) }
        created_at.should == created_at.sort{|a, b| b <=> a } 
      end
    end

    context "Sort by oldest" do
      it "should get default testimonials in normal chronological order" do

        # Make sure one testimonial is older than the other.
        testimonial = @user.testimonials.first
        testimonial.created_at = Time.now - 2.days
        testimonial.save

        get :index, {
          apikey: @user.apikey,
          sort: "oldest",
          format: "json"
        }

        response.should be_success
        data = MultiJson.decode(response.body)

        created_at = data["testimonials"].map{ |a| Time.parse(a["created_at"]) }
        created_at.should == created_at.sort{|a, b| a <=> b }
      end
    end

    context "set limit to 1" do
      it "should return 1 testimonial and provide next url to page 2" do
        @user.tconfig.per_page = 1
        @user.tconfig.save

        get :index, {
          apikey: @user.apikey,
          format: "json"
        }

        response.should be_success
        data = MultiJson.decode(response.body)

        data["update_data"]["nextPageUrl"].should include("page=2")
        data["update_data"]["nextPage"].should == 2
        data["testimonials"].count.should == 1
      end

      context "get next page" do
        it "should return 1 testimonial and provide next url to page 3" do
          @user.tconfig.per_page = 1
          @user.tconfig.save

          get :index, {
            apikey: @user.apikey,
            format: "json",
            page: 2
          }

          response.should be_success
          data = MultiJson.decode(response.body)

          data["update_data"]["nextPageUrl"].should include("page=3")
          data["update_data"]["nextPage"].should == 3
          data["testimonials"].count.should == 1
        end
      end
    end
 end
end
