FactoryGirl.define do

  factory :grant do
    transient { n { rand(9999) } }
    association        :funder, factory: :funder
    association        :recipient, factory: :recipient
    grant_identifier   { "360G-esmeefairbairn-12-0732#{n}" }
    title              'Grant to Charity Projects'
    description        'Towards core costs of an organisation.'
    currency           'GBP'
    funding_programme  'Main Grant'
    amount_awarded     40000
    award_date         { Date.new(Date.today.year, 3, 9) }
    planned_start_date { Date.new(Date.today.year, 3, 9) }
    planned_end_date   { Date.new(Date.today.year + 1, 3, 9) }

    factory :review_grant, class: Grant do
      state             'review'
      type_of_funding   Grant::FUNDING_TYPE[0][1]
      operating_for     Grant::OPERATING_FOR[0][1]
      income            Grant::INCOME[0][1]
      employees         Grant::EMPLOYEES[0][1]
      volunteers        Grant::EMPLOYEES[0][1]
      affect_people     true
      gender            Grant::GENDERS.first
      affect_other      false
      geographic_scale  Grant::GEOGRAPHIC_SCALE[0][1]

      factory :approved_grant, class: Grant do
        state           'approved'
      end
    end
  end
end
