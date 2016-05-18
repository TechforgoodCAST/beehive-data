FactoryGirl.define do
  factory :stakeholder do
    association :beneficiary, factory: :beneficiary
    association :grant, factory: :grant
  end
end
