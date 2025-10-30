FactoryBot.define do
  factory :property do
    name { "#{Faker::Adjective.positive.capitalize} #{['House', 'Villa', 'Apartment', 'Condo'].sample}" }

    trait :with_few_photos do
      after(:create) do |property|
        create(:photo, property: property, position: 1)
        create(:photo, property: property, position: 2)
      end
    end

    trait :with_cover_photo do
      after(:create) do |property|
        create(:photo, property: property, position: 1)
        create(:photo, property: property, position: 2)
        create(:photo, property: property, position: 3)
        create(:photo, property: property, position: 4)
      end
    end

    trait :with_many_photos do
      after(:create) do |property|
        (1..5).each do |position|
          create(:photo, property: property, position: position)
        end
      end
    end
  end
end
