FactoryGirl.define do
  factory :region do
    association :district, factory: :district
    association :grant, factory: :grant
  end
end
