FactoryBot.define do
  factory :photo do
    association :property
    sequence(:filename) { |n| "photo_#{n}.jpg" }
    position { nil }
    content_type { "image/jpeg" }
    file_size { rand(100_000..2_000_000) }

    trait :png do
      content_type { "image/png" }
      filename { "#{filename.split('.').first}.png" }
    end

    trait :large do
      file_size { 8_000_000 }
    end

    trait :cover do
      position { 3 }
    end
  end
end
