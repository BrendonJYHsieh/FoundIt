class MatchesController < ApplicationController
  before_action :require_login
  before_action :set_match, only: [:show, :approve, :reject]

  # All matches related to the current user (as finder or loser)
  def index
    @matches = Match
               .left_joins(:lost_item, :found_item)
               .where('lost_items.user_id = ? OR found_items.user_id = ?', current_user.id, current_user.id)
               .order(created_at: :desc)
  end

  # Single match detail view
  def show
  end

  # Only the poster of the found item can approve
  def approve
    if @match.found_item&.user == current_user
      @match.update!(status: 'approved')
      flash[:notice] = "✅ Match approved successfully!"
    else
      flash[:alert] = "You cannot approve this match."
    end
    redirect_to match_path(@match)
  end

  # Only the poster of the found item can reject
  def reject
    if @match.found_item&.user == current_user
      @match.update!(status: 'rejected')
      flash[:alert] = "❌ Match rejected."
    else
      flash[:alert] = "You cannot reject this match."
    end
    redirect_to match_path(@match)
  end

  private

  def set_match
    @match = Match.find(params[:id])
  end
end
