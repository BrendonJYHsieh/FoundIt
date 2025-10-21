class FindMatchesJob < ApplicationJob
  queue_as :default

  def perform(item)
    if item.is_a?(LostItem)
      find_matches_for_lost_item(item)
    elsif item.is_a?(FoundItem)
      find_matches_for_found_item(item)
    end
  end

  private

  def find_matches_for_lost_item(lost_item)
    # Find potential matches based on item type, location, and date proximity
    potential_found_items = FoundItem.active
                                   .by_type(lost_item.item_type)
                                   .where('found_date >= ? AND found_date <= ?', 
                                          lost_item.lost_date - 7.days, 
                                          lost_item.lost_date + 7.days)
                                   .limit(5)

    potential_found_items.each do |found_item|
      similarity_score = calculate_similarity(lost_item, found_item)
      
      if similarity_score >= 0.5 # Minimum threshold for creating a match
        Match.create!(
          lost_item: lost_item,
          found_item: found_item,
          similarity_score: similarity_score,
          status: 'pending'
        )
      end
    end
  end

  def find_matches_for_found_item(found_item)
    # Find potential matches based on item type, location, and date proximity
    potential_lost_items = LostItem.active
                                  .by_type(found_item.item_type)
                                  .where('lost_date >= ? AND lost_date <= ?', 
                                         found_item.found_date - 7.days, 
                                         found_item.found_date + 7.days)
                                  .limit(5)

    potential_lost_items.each do |lost_item|
      similarity_score = calculate_similarity(lost_item, found_item)
      
      if similarity_score >= 0.5 # Minimum threshold for creating a match
        Match.create!(
          lost_item: lost_item,
          found_item: found_item,
          similarity_score: similarity_score,
          status: 'pending'
        )
      end
    end
  end

  def calculate_similarity(lost_item, found_item)
    score = 0.0
    total_weight = 0.0

    # Item type match (40% weight)
    if lost_item.item_type == found_item.item_type
      score += 0.4
    end
    total_weight += 0.4

    # Location proximity (30% weight)
    if lost_item.location == found_item.location
      score += 0.3
    elsif similar_locations?(lost_item.location, found_item.location)
      score += 0.15
    end
    total_weight += 0.3

    # Date proximity (20% weight)
    days_diff = (lost_item.lost_date.to_date - found_item.found_date.to_date).abs
    if days_diff <= 1
      score += 0.2
    elsif days_diff <= 3
      score += 0.15
    elsif days_diff <= 7
      score += 0.1
    end
    total_weight += 0.2

    # Description similarity (10% weight)
    description_similarity = calculate_text_similarity(lost_item.description, found_item.description)
    score += description_similarity * 0.1
    total_weight += 0.1

    # Normalize score
    total_weight > 0 ? score / total_weight : 0.0
  end

  def similar_locations?(loc1, loc2)
    # Simple location similarity check
    common_words = loc1.downcase.split & loc2.downcase.split
    common_words.length >= 1
  end

  def calculate_text_similarity(text1, text2)
    # Simple text similarity using common words
    words1 = text1.downcase.split
    words2 = text2.downcase.split
    common_words = words1 & words2
    total_words = (words1 + words2).uniq.length
    
    total_words > 0 ? common_words.length.to_f / total_words : 0.0
  end
end
