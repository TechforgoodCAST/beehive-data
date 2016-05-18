FactoryGirl.define do
  factory :age do
    association :age_group, factory: :age_group
    association :grant, factory: :grant
  end
end
