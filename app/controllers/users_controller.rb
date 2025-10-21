class UsersController < ApplicationController
  before_action :require_login, only: [:show, :edit, :update]
  before_action :set_user, only: [:show, :edit, :update]
  
  def new
    redirect_to dashboard_path if current_user
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      # In a real app, you would send a verification email here
      @user.update!(verified: true) # For MVP, auto-verify
      session[:user_id] = @user.id
      redirect_to dashboard_path, notice: 'Account created successfully!'
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'Profile updated successfully!'
    else
      render :edit
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end
end
