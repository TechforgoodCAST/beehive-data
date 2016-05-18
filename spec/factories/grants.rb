FactoryGirl.define do

  factory :grant do
    transient { n { rand(9999) } }
    association       :funder, factory: :funder
    association       :recipient, factory: :recipient

    factory :grants, class: Grant do
      grant_identifier  { "360G-esmeefairbairn-12-0732#{n}" }
      title             'Grant to Charity Projects'
      description       'Towards core costs of an organisation.'
      currency          'GBP'
      funding_programme 'Main Grant'
      amount_awarded    40000
      award_date        Date.new(2015, 3, 9)

      factory :review_grant, class: Grant do
        state           'review'
        # age_groups      { FactoryGirl.create_list(:age_group, 8) }
      end
    end
  end
end
