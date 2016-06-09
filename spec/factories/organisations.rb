FactoryGirl.define do

  factory :organisation do
    transient   { n { rand(9999) } }
    association :country, factory: :country

    factory :funder, class: Organisation do
      publisher               true
      license                 'http://esmeefairbairn.org.uk/what-we-fund/open-data/'
      name                    'Esmee Fairbairn Foundation'
      organisation_identifier { "GB-CHC-#{n}" }
      charity_number          { "CHC-#{n}" }
    end

    factory :recipient, class: Organisation do
      name                    'Charity Projects'
      organisation_identifier { "GB-CHC-#{n}" }
      charity_number          { "CHC-#{n}" }
      company_number          { "COH-#{n}" }

      factory :review_org, class: Organisation do
        state          'review'
        street_address '123 street'
        city           'London'
        region         'London'
        postal_code    '123 ABC'
        multi_national false

        factory :approved_org, class: Organisation do
          state        'approved'
        end
      end
    end
  end

end
