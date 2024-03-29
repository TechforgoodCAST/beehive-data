FactoryGirl.define do
  factory :district do
    association :country, factory: :country
    sequence(:name, (0..2).cycle) { |i| ['Arun', 'Ashfield', 'Ashford'][i] }
    sequence(:subdivision, (0..2).cycle) { |i| ['45UC', '37UB', '29UB'][i] }
    sequence(:region, (0..2).cycle) { |i| ['South East', 'East Midlands', 'South East'][i] }
    sequence(:sub_country, (0..2).cycle) { |i| ['England', 'England', 'England'][i] }
  end

  factory :kenya_district, class: District do
    association :country, factory: :country
    sequence(:name, (0..2).cycle) { |i| ['Mombasa', 'Kwale', 'Kilifi'][i] }
    sequence(:subdivision, (0..2).cycle) { |i| ['1', '2', '3'][i] }
  end

  factory :blank_district, class: District do
    association :country, factory: :country
  end
end
