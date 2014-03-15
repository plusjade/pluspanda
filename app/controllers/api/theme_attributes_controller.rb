class Api::ThemeAttributesController < ApplicationController

  layout false

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render(nothing: true, status: :unauthorized)
  end

  before_filter {
    @user = User.find(params[:id])
    authorize! :edit, @user
  }

  # get staged copy of staged attribute
  def staged
    attribute = load_attribute
    tokens = if attribute.attribute_name == "testimonial.html"
                Testimonial.api_attributes.map{ |a| "{{#{ a }}}" }
            elsif attribute.attribute_name == "wrapper.html"
              [
                "{{testimonials}}",
                "{{tag_list}}",
                "{{count}}",
                "{{form_link:Link Text}}"
              ]
            else
              []
            end


    render json: {
      body: attribute.staged,
      tokens: tokens
    }
  end

  # get original attributes from theme source for currently staged theme.
  def original
    theme_package = ThemePackage.new(@user.standard_themes.get_staged.theme_name)
    render json: {
      body: theme_package.get_attribute(load_attribute.attribute_name)
    }
  end

  # update staged copy of staged attribute.
  def update
    if load_attribute.update_attributes(:staged => params[:body])
      @status  = "good"
      @message = "Theme data updated."
    else
      @message = "There was a problem saving the theme data."
    end

    serve_json_response
  end

  private

  def load_attribute
    raise ActiveRecord::NotFound unless ThemeAttribute::Names.include?(params[:attribute])

    @user.standard_themes.get_staged.get_attribute(params[:attribute])
  end
end
