class LostItemsController < ApplicationController
  before_action :require_login
  before_action :set_lost_item, only: [:show, :edit, :update, :destroy, :mark_found, :close]
  
  def index
    @lost_items = current_user.lost_items.includes(:matches)
    @lost_items = @lost_items.by_type(params[:item_type]) if params[:item_type].present?
    @lost_items = @lost_items.by_location(params[:location]) if params[:location].present?
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
  end

  def update
    if @lost_item.update(lost_item_params)
      redirect_to @lost_item, notice: 'Lost item updated successfully!'
    else
      render :edit
    end
  end

  def destroy
    @lost_item.destroy
    redirect_to lost_items_path, notice: 'Lost item deleted successfully!'
  end

  def mark_found
    @lost_item.mark_as_found!
    redirect_to @lost_item, notice: 'Item marked as found!'
  end

  def close
    @lost_item.close!
    redirect_to @lost_item, notice: 'Lost item post closed!'
  end

  private

  def set_lost_item
    @lost_item = current_user.lost_items.find(params[:id])
  end

  def lost_item_params
    params.require(:lost_item).permit(:item_type, :description, :location, :lost_date, :verification_questions_array)
  end
end
