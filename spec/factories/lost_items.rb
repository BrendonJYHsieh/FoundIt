# spec/factories/lost_items.rb
FactoryBot.define do
  factory :lost_item do
    association :user
    item_type { "phone" }
    description { "iPhone 13 Pro Max, black case, lost near Butler Library" }
    location { "Butler Library" }
    lost_date { Date.current }
    status { "active" }
    # Photos are now handled by Active Storage has_many_attached :photos

    trait :found do
      status { "found" }
    end

    trait :closed do
      status { "closed" }
    end

    trait :with_verification_questions do
      verification_questions { '[{"question": "What color is the case?", "answer": "black"}]' }
    end
  end
end
