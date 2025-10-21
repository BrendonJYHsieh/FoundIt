class User < ApplicationRecord
  has_secure_password
  
  has_many :lost_items, dependent: :destroy
  has_many :found_items, dependent: :destroy
  has_many :matches_as_loser, through: :lost_items, source: :matches
  has_many :matches_as_finder, through: :found_items, source: :matches
  
  validates :email, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@columbia\.edu\z/i }
  validates :uni, presence: true, uniqueness: true, format: { with: /\A[a-z]{2,3}\d{4}\z/i }
  validates :reputation_score, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  before_validation :set_defaults
  before_validation :extract_uni_from_email
  
  scope :verified, -> { where(verified: true) }
  
  def columbia_email?
    email&.ends_with?('@columbia.edu')
  end
  
  def increment_reputation(points = 1)
    update!(reputation_score: reputation_score + points)
  end
  
  def good_samaritan?
    reputation_score >= 10
  end
  
  private
  
  def set_defaults
    self.verified ||= false
    self.reputation_score ||= 0
  end
  
  def extract_uni_from_email
    if email.present? && email.include?('@columbia.edu')
      self.uni = email.split('@').first.downcase
    end
  end
end
