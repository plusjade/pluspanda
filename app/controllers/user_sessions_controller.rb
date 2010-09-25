class UserSessionsController < ApplicationController
  layout "frontpage"
  
  def new
    redirect_to admin_path if current_user
    @user_session = UserSession.new
  end
  
  def create
    redirect_to admin_path if current_user
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_to admin_path
    else
      # try to login at the old site teehee
      email    = params[:user_session][:email]
      password = params[:user_session][:password]
      response = Net::HTTP.post_form(URI.parse('http://old.pluspanda.com/admin/login'),
                                    {'email'=> email , 'password'=> password })
      r        = ActiveSupport::JSON.decode(response.body)
      
      if r['status'] == 'good'
        user = User.find_by_email(email)
        puts user
        user.password = password
        user.password_confirmation = password
        if user.save
          if @user_session.save
            redirect_to admin_path
            return
          end
        end
        puts user.errors
      end
      
      flash[:notice] = "Incorrect login information"
      render :action => :new
    end
  end
  
end
