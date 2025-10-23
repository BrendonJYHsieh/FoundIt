class DashboardController < ApplicationController
  before_action :require_login
  
  def index
    @user = current_user
    @lost_items = @user.lost_items.active.recent.limit(5)
    @found_items = @user.found_items.active.recent.limit(5)
    @pending_matches = Match.left_joins(:lost_item, :found_item)
                        .where('lost_items.user_id = ? OR found_items.user_id = ?', @user.id, @user.id)
                        .where(status: 'matched')
                        .limit(5)
    @recent_activity = get_recent_activity
  end

  private

  def get_recent_activity
    activities = []
    
    # Add recent lost items
    @user.lost_items.recent.each do |item|
      activities << {
        type: 'lost_item',
        item: item,
        date: item.created_at,
        description: "Posted lost #{item.item_type}"
      }
    end
    
    # Add recent found items
    @user.found_items.recent.each do |item|
      activities << {
        type: 'found_item',
        item: item,
        date: item.created_at,
        description: "Posted found #{item.item_type}"
      }
    end
    
    # Add recent matches
    Match.joins(:lost_item, :found_item)
         .where('lost_items.user_id = ? OR found_items.user_id = ?', @user.id, @user.id)
         .where('matches.created_at >= ?', 30.days.ago).each do |match|
      activities << {
        type: 'match',
        item: match,
        date: match.created_at,
        description: "New match found (#{(match.similarity_score * 100).round}% similarity)"
      }
    end
    
    activities.sort_by { |a| a[:date] }.reverse.first(10)
  end
end
