class FoundItemsController < ApplicationController
  before_action :require_login, except: [:index, :show]

  def new
    @found_item = FoundItem.new(found_date: Date.today)
  end

  def create
    @found_item = current_user.found_items.new(found_item_params)

    if @found_item.save
      redirect_to @found_item, notice: "Your found item has been posted."
    else
      flash.now[:alert] = "Please fix the errors below."
      render :new, status: :unprocessable_entity
    end
  end

  def index
    # only show the logged-in user's found items for now
    @found_items = current_user.found_items.order(found_date: :desc)
  end   

  def show
    @found_item = FoundItem.find(params[:id])
  end

  def mark_returned
    @found_item = FoundItem.find(params[:id])

    if @found_item.user == current_user
      @found_item.mark_as_returned!
      flash[:notice] = "🎉 Item marked as returned! Reputation +5."
    else
      flash[:alert] = "Could not mark as returned."
    end

    redirect_to @found_item
  end

  def close
    @found_item = FoundItem.find(params[:id])
  
    if @found_item.user == current_user
      @found_item.close!
      flash[:notice] = "📦 Listing closed successfully."
    else
      flash[:alert] = "Could not close this listing."
    end
  
    redirect_to @found_item
  end

  def feed
    @found_items = FoundItem.active.includes(:user).order(created_at: :desc)
  end 

  def claim
    @found_item = FoundItem.find(params[:id])
  
    if @found_item.user != current_user && @found_item.status == 'active'
      match = Match.create!(
        lost_item: nil,
        found_item: @found_item,
        claimer: current_user,
        similarity_score: 1.0,
        status: 'matched'
      )
      flash[:notice] = "✅ Claim request sent to the poster!"
    else
      flash[:alert] = "You cannot claim this item."
    end
  
    redirect_to feed_found_items_path
  end  
  

  private

  def found_item_params
    data = params.require(:found_item).permit(
      :item_type, :description, :location, :found_date, :status, :photos
    )
    
    # Clean and validate photo URLs
    if data[:photos].present?
      valid_urls = clean_image_urls(data[:photos])
      data[:photos] = valid_urls.to_json
    else
      data[:photos] = '[]'
    end
  
    data
  end  
end
