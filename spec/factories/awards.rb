FactoryGirl.define do
  factory :award do
    association :grant, factory: :grant
    association :recipient, factory: :recipient
  end
end
