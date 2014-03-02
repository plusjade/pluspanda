require 'spec_helper'

describe "api requests" do

  before(:all) do
    @user = create_user
    @apikey = "?apikey=#{@user.apikey}"
    @testimonial = Testimonial.first
  end

  after(:all) do
    @user.destroy
  end

  it "should return success status" do
    get "/"
    response.should be_success
  end

  it "widget should return success status" do
    get widget_testimonials_path + ".js" + @apikey

    puts response.inspect
    response.should be_success

    # ensure javascript was rendered
    response.body.gsub!("var pandaSettings = {", "").should_not == nil
  end

  describe "getting testimonials... " do

    it "should return success status" do
      get testimonials_path + @apikey

      response.should be_success

      response.body.should == "a standalone version maybe?"
    end

    it "should return success status" do
      get testimonials_path + ".json" + @apikey

      response.should be_success

      body = ActiveSupport::JSON.decode(response.body)

      body["testimonials"].should be_a_kind_of(Array)

      # 3 sample testimonials
      body["testimonials"].count.should == 3
    end

    it "should return success status" do
      get testimonials_path + ".js" + @apikey

      response.should be_success

      # this is the js function
      response.body.gsub!("panda.display(", "").should_not == nil
    end

  end

  describe "adding testimonials..." do 

    it "public form should return success status" do
      get new_testimonial_path

      response.body.should == "error! invalid apikey"
      response.should be_success
    end

    it "public form should return success status" do
      get new_testimonial_path + @apikey
      response.should be_success
    end

  end

  it "edit form should return success status" do
    get edit_testimonial_path(@testimonial) + @apikey

    response.should be_success
  end

end