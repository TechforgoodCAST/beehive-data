FactoryGirl.define do
  factory :country do
    sequence(:name, (0..1).cycle) { |i| ['United Kingdom', 'Kenya'][i] }
    sequence(:alpha2, (0..1).cycle) { |i| ['GB', 'KE'][i] }
    sequence(:currency_code, (0..1).cycle) { |i| ['GBP', 'KES'][i] }
  end
end
