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
    name = ThemeAttribute::Names[attribute.name]
    tokens = if name == "testimonial.html"
                Testimonial.api_attributes.map{ |a| "{{#{ a }}}" }
            elsif name == "wrapper.html"
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
    render json: {
      body: @user.standard_themes.get_staged.get_attribute_original_by_index(load_attribute.name)
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
