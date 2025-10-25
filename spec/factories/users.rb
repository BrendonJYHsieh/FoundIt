# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@columbia.edu" }
    sequence(:uni) { |n| "abc#{n.to_s.rjust(4, '0')}" }
    first_name { "John" }
    last_name { "Doe" }
    password { "password123" }
    password_confirmation { "password123" }
    verified { true }
    reputation_score { 0 }
    contact_preference { "email" }
    profile_visibility { "public" }
    last_active_at { nil }

    trait :with_profile do
      bio { "Computer Science student" }
      phone { "555-123-4567" }
    end

    trait :high_reputation do
      reputation_score { 15 }
    end

    trait :verified do
      verified { true }
    end

    trait :unverified do
      verified { false }
    end
  end
end
