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
      @user_session.record.update_attributes(:last_login_at => Time.now)
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
  
  def single_access
    @user = User.find_by_single_access_token(params[:single_access_token])
    
    if @user
      current_user_session.destroy if current_user_session
      UserSession.find.destroy if UserSession.find

      UserSession.create(@user)
      @user.single_access_token = ActiveSupport::SecureRandom.hex(10)
      @user.save
    end

    redirect_to admin_path
  end
  
end
