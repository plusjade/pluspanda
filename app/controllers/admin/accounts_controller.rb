class Admin::AccountsController < ApplicationController
  
  layout proc { |c| c.request.xhr? ? false : "admin"}
  before_filter :require_user, :setup_user

  def show
    @user = @current_user
  end

  def update
    if @current_user.update_attributes(params[:user])
      @status  = "good"
      @message = "Account Updated!"
    elsif !@user.valid?
      @message = 'Oops! Please make sure all fields are valid!'
    end

    serve_json_response and return
  end


end