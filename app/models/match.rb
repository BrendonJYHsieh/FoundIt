# class Match < ApplicationRecord
#   belongs_to :lost_item, optional: true
#   belongs_to :found_item
#   belongs_to :claimer, class_name: 'User', optional: true

#   validates :status, inclusion: { in: %w[matched claimed approved rejected] }

#   before_validation :set_defaults

#   scope :pending, -> { where(status: 'pending') }
#   scope :verified, -> { where(status: 'verified') }
#   scope :high_similarity, -> { where('similarity_score >= ?', 0.7) }
#   scope :recent, -> { where('created_at >= ?', 30.days.ago) }
  
#   def verification_answers_array
#     JSON.parse(verification_answers || '{}')
#   end
  
#   def verification_answers_array=(answers)
#     self.verification_answers = answers.to_json
#   end
  
#   def verify_answers!(answers)
#     questions = lost_item.verification_questions_array
#     correct_answers = 0
    
#     questions.each_with_index do |question, index|
#       if answers[index.to_s] == question['answer']
#         correct_answers += 1
#       end
#     end
    
#     if correct_answers >= questions.length * 0.8 # 80% correct
#       update!(status: 'verified', verification_answers_array: answers)
#       true
#     else
#       update!(status: 'rejected', verification_answers_array: answers)
#       false
#     end
#   end
  
#   def complete!
#     update!(status: 'completed')
#     lost_item.mark_as_found!
#     found_item.mark_as_returned!
#   end
  
#   def reject!
#     update!(status: 'rejected')
#   end
  
#   private
  
#   def set_defaults
#     self.status ||= 'pending'
#     self.verification_answers ||= '{}'
#   end
# end

class Match < ApplicationRecord
  belongs_to :lost_item, optional: true
  belongs_to :found_item
  belongs_to :claimer, class_name: "User", optional: true

  validates :similarity_score, presence: true, numericality: { in: 0.0..1.0 }
  validates :status, presence: true, inclusion: { in: %w[pending matched claimed approved rejected] }

  before_validation :set_defaults

  # -------------------------------
  # Scopes
  # -------------------------------
  scope :pending,  -> { where(status: 'pending') }
  scope :matched,  -> { where(status: 'matched') }
  scope :claimed,  -> { where(status: 'claimed') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :recent,   -> { where('created_at >= ?', 30.days.ago) }

  # -------------------------------
  # JSON Helpers
  # -------------------------------
  def verification_answers_array
    JSON.parse(verification_answers || '{}')
  end

  def verification_answers_array=(answers)
    self.verification_answers = answers.to_json
  end

  # -------------------------------
  # Lifecycle Methods
  # -------------------------------
  def claim!
    update!(status: 'claimed')
  end

  def approve!
    update!(status: 'approved')
    lost_item.mark_as_found!
    found_item.mark_as_returned!
  end

  def reject!
    update!(status: 'rejected')
  end

  # -------------------------------
  # Internal
  # -------------------------------
  private

  def set_defaults
    self.status ||= 'pending'
    self.verification_answers ||= '{}'
  end
end
