FactoryGirl.define do
  factory :book do
    name { Faker::Lorem.words(3+Random.rand(3)).map(&:capitalize).join(" ") }
  end
end
