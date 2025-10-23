# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@columbia.edu" }
    sequence(:uni) { |n| "ts#{n.to_s.rjust(4, '0')}" }
    first_name { "Test" }
    last_name { "User" }
    password { "password123" }
    password_confirmation { "password123" }
    verified { true }
    reputation_score { 0 }

    trait :unverified do
      verified { false }
    end

    trait :good_samaritan do
      reputation_score { 15 }
    end

    trait :with_profile do
      first_name { "John" }
      last_name { "Doe" }
      bio { "Test bio" }
      phone { "555-123-4567" }
      contact_preference { "email" }
      profile_visibility { "public" }
    end
  end
end
