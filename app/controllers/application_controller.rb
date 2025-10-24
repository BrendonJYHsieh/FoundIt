class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # Disable CSRF protection for now - will fix later
  skip_before_action :verify_authenticity_token
  
  helper_method :current_user, :logged_in?
  
  # Include helper methods in controllers
  include ApplicationHelper
  
  private
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
    nil
  end
  
  def logged_in?
    !!current_user
  end
  
  def require_login
    unless logged_in?
      flash[:alert] = "Please log in to access this page."
      redirect_to login_path
    end
  end
  
  def require_verified_user
    unless current_user&.verified?
      flash[:alert] = "Please verify your email to access this feature."
      redirect_to dashboard_path
    end
  end
end
