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
    @recent_lost_items = @user.lost_items.order(created_at: :desc).limit(5)
    @recent_found_items = @user.found_items.order(created_at: :desc).limit(5)
    
    # Get matches where user is either the loser or finder
    @recent_matches = Match.joins(:lost_item, :found_item)
                          .where("lost_items.user_id = ? OR found_items.user_id = ?", @user.id, @user.id)
                          .order(created_at: :desc)
                          .limit(5)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      @user.update!(last_active_at: Time.current)
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
    params.require(:user).permit(:first_name, :last_name, :bio, :phone, 
                                :profile_photo, :contact_preference, 
                                :profile_visibility, :password, :password_confirmation)
  end
end
