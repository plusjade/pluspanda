class ChargesController < ApplicationController
  def create
    @user = User.find(params[:id])
    authorize! :edit, @user

    plan = "yearly-36"

    if @user.stripe_id.present?
      customer = Stripe::Customer.retrieve(@user.stripe_id)
      customer.plan = plan
      customer.save
    else
      customer = Stripe::Customer.create(
        :email => @user.email,
        :card  => params[:stripeToken],
        :plan  => plan
      )

      @user.stripe_id = customer.id
    end

    @user.premium = true
    @user.save

    flash[:success] = "Thanks, your account is upgraded!"
  rescue Stripe::CardError, Stripe::InvalidRequestErro => e
    flash[:error] = e.message
  ensure
    redirect_to admin_path
  end
end
