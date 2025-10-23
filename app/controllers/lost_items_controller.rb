class LostItemsController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :set_lost_item, only: [:show, :edit, :update, :destroy, :mark_found, :close]
  
  def index
    # Show only the logged-in user's lost items
    @lost_items = current_user.lost_items.includes(:matches).order(lost_date: :desc)
    @lost_items = @lost_items.by_type(params[:item_type]) if params[:item_type].present?
    @lost_items = @lost_items.by_location(params[:location]) if params[:location].present?
  end

  def all
    # Show all lost items from all users
    @viewing_all = true
    @lost_items = LostItem.includes(:user, :matches).order(lost_date: :desc)
    @lost_items = @lost_items.by_type(params[:item_type]) if params[:item_type].present?
    @lost_items = @lost_items.by_location(params[:location]) if params[:location].present?
    render :index
  end

  def show
    @matches = @lost_item.matches.includes(:found_item).order(similarity_score: :desc)
  end

  def new
    @lost_item = current_user.lost_items.build
  end

  def create
    @lost_item = current_user.lost_items.build(lost_item_params)
    
    if @lost_item.save
      redirect_to @lost_item, notice: 'Lost item posted successfully!'
    else
      render :new
    end
  end

  def edit
    unless @lost_item.user == current_user
      flash[:alert] = "You can only edit your own lost items."
      redirect_to @lost_item
    end
  end

  def update
    unless @lost_item.user == current_user
      flash[:alert] = "You can only edit your own lost items."
      redirect_to @lost_item
      return
    end
    
    if @lost_item.update(lost_item_params)
      redirect_to @lost_item, notice: 'Lost item updated successfully!'
    else
      render :edit
    end
  end

  def destroy
    unless @lost_item.user == current_user
      flash[:alert] = "You can only delete your own lost items."
      redirect_to @lost_item
      return
    end
    
    @lost_item.destroy
    redirect_to lost_items_path, notice: 'Lost item deleted successfully!'
  end

  def mark_found
    unless @lost_item.user == current_user
      flash[:alert] = "You can only mark your own items as found."
      redirect_to @lost_item
      return
    end
    
    @lost_item.mark_as_found!
    redirect_to @lost_item, notice: 'Item marked as found!'
  end

  def close
    unless @lost_item.user == current_user
      flash[:alert] = "You can only close your own lost item posts."
      redirect_to @lost_item
      return
    end
    
    @lost_item.close!
    redirect_to @lost_item, notice: 'Lost item post closed!'
  end

  def feed
    @lost_items = LostItem.active.includes(:user).order(created_at: :desc)
  end

  private

  def set_lost_item
    @lost_item = LostItem.find(params[:id])
  end

  def lost_item_params
    data = params.require(:lost_item).permit(
      :item_type, :description, :location, :lost_date, :status, :photos
    )
    # convert comma-separated photo URLs into JSON array for model storage
    if data[:photos].present?
      urls = data[:photos].split(/[\s,]+/).map(&:strip).reject(&:blank?)
      data[:photos] = urls.to_json
    else
      data[:photos] = '[]'
    end
  
    data
  end
end
