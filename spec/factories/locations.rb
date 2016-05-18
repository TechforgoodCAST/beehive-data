FactoryGirl.define do
  factory :location do
    association :country, factory: :country
    association :grant, factory: :grant
  end
end
