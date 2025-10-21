class LostItem < ApplicationRecord
  belongs_to :user
  has_many :matches, dependent: :destroy
  has_many :found_items, through: :matches
  
  validates :item_type, presence: true, inclusion: { in: %w[phone laptop textbook id keys wallet backpack other] }
  validates :description, presence: true, length: { minimum: 10, maximum: 500 }
  validates :location, presence: true
  validates :lost_date, presence: true
  validates :status, presence: true, inclusion: { in: %w[active found closed] }
  validates :verification_questions, presence: true
  
  before_validation :set_defaults
  after_create :find_potential_matches
  
  scope :active, -> { where(status: 'active') }
  scope :by_type, ->(type) { where(item_type: type) }
  scope :by_location, ->(location) { where(location: location) }
  scope :recent, -> { where('lost_date >= ?', 30.days.ago) }
  
  def verification_questions_array
    JSON.parse(verification_questions || '[]')
  end
  
  def verification_questions_array=(questions)
    self.verification_questions = questions.to_json
  end
  
  def photos_array
    JSON.parse(photos || '[]')
  end
  
  def photos_array=(photo_urls)
    self.photos = photo_urls.to_json
  end
  
  def find_potential_matches
    FindMatchesJob.perform_later(self)
  end
  
  def mark_as_found!
    update!(status: 'found')
    matches.pending.update_all(status: 'cancelled')
  end
  
  def close!
    update!(status: 'closed')
  end
  
  private
  
  def set_defaults
    self.status ||= 'active'
    self.verification_questions ||= '[]'
    self.photos ||= '[]'
  end
end
