# spec/factories/found_items.rb
FactoryBot.define do
  factory :found_item do
    association :user
    item_type { "phone" }
    description { "iPhone 13 Pro Max, black case, found in Butler Library" }
    location { "Butler Library" }
    found_date { Date.current }
    status { "active" }
    photos { "[]" }

    trait :with_photos do
      photos { '["photo1.jpg", "photo2.jpg"]' }
    end

    trait :returned do
      status { "returned" }
    end

    trait :closed do
      status { "closed" }
    end
  end
end
