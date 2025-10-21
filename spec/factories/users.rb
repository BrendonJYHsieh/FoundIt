# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@columbia.edu" }
    sequence(:uni) { |n| "ts#{n.to_s.rjust(4, '0')}" }
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
  end
end
