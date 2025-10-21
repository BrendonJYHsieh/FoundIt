# spec/factories/lost_items.rb
FactoryBot.define do
  factory :lost_item do
    association :user
    item_type { "phone" }
    description { "iPhone 13 Pro with blue case" }
    location { "Butler Library" }
    lost_date { 1.day.ago }
    verification_questions { '[{"question": "What color is the phone case?", "answer": "Blue"}]' }
    status { "active" }

    trait :found do
      status { "found" }
    end

    trait :closed do
      status { "closed" }
    end

    trait :laptop do
      item_type { "laptop" }
      description { "MacBook Pro 13-inch" }
    end

    trait :textbook do
      item_type { "textbook" }
      description { "Introduction to Computer Science" }
    end
  end
end
