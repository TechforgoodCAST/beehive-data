FactoryGirl.define do
  factory :district do
    association :country, factory: :country
    name        'Birmingham'
    subdivision '00CN'
    region      'West Midlands'
    sub_country 'England'
  end
end
