# spec/factories/found_items.rb
FactoryBot.define do
  factory :found_item do
    association :user
    item_type { "phone" }
    description { "iPhone 13 Pro with blue case" }
    location { "Butler Library" }
    found_date { 1.day.ago }
    status { "active" }

    trait :returned do
      status { "returned" }
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
