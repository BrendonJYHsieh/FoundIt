class SessionsController < ApplicationController
  def new
    redirect_to dashboard_path if current_user
  end

  def create
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password])
      if user.verified?
        session[:user_id] = user.id
        redirect_to dashboard_path, notice: 'Successfully logged in!'
      else
        flash.now[:alert] = 'Please verify your email before logging in.'
        render :new
      end
    else
      flash.now[:alert] = 'Invalid email or password.'
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: 'Successfully logged out!'
  end
end
