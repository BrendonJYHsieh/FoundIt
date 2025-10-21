# spec/factories/matches.rb
FactoryBot.define do
  factory :match do
    association :lost_item
    association :found_item
    similarity_score { 0.85 }
    status { "pending" }
    verification_answers { "{}" }

    trait :verified do
      status { "verified" }
    end

    trait :rejected do
      status { "rejected" }
    end

    trait :completed do
      status { "completed" }
    end

    trait :high_similarity do
      similarity_score { 0.95 }
    end

    trait :low_similarity do
      similarity_score { 0.60 }
    end
  end
end
