class FoundItem < ApplicationRecord
  belongs_to :user
  has_many :matches, dependent: :destroy
  has_many :lost_items, through: :matches
  
  validates :item_type, presence: true, inclusion: { in: %w[phone laptop textbook id keys wallet backpack other] }
  validates :description, presence: true, length: { minimum: 10, maximum: 500 }
  validates :location, presence: true
  validates :found_date, presence: true
  validates :status, presence: true, inclusion: { in: %w[active returned closed] }
  
  before_validation :set_defaults
  after_create :find_potential_matches
  
  scope :active, -> { where(status: 'active') }
  scope :by_type, ->(type) { where(item_type: type) }
  scope :by_location, ->(location) { where(location: location) }
  scope :recent, -> { where('found_date >= ?', 30.days.ago) }
  
  def photos_array
    JSON.parse(photos || '[]')
  end
  
  def photos_array=(photo_urls)
    self.photos = photo_urls.to_json
  end
  
  def find_potential_matches
    FindMatchesJob.perform_later(self)
  end
  
  def mark_as_returned!
    update!(status: 'returned')
    matches.pending.update_all(status: 'cancelled')
    user.increment_reputation(5) # Reward for returning item
  end
  
  def close!
    update!(status: 'closed')
    matches.pending.update_all(status: 'cancelled')
  end
  
  private
  
  def set_defaults
    self.status ||= 'active'
    self.photos ||= '[]'
  end
end
