json.array! grants do |grant|

  json.ignore_nil!

  json.publisher grant.funder.name
  json.license   grant.funder.license

  json.extract! grant, :grant_identifier
  json.funder          grant.funder.name
  json.extract! grant, :award_year, :funding_programme, :title, :description,
                       :currency, :amount_applied_for, :amount_awarded,
                       :amount_disbursed, :award_date, :planned_start_date,
                       :planned_end_date, :open_call
  json.type_of_funding Grant::FUNDING_TYPE[grant.type_of_funding][0] if grant.type_of_funding

  json.recipient do
    json.extract! grant.recipient, :organisation_identifier
    json.country                   grant.recipient.country.alpha2
    json.organisation_type         Organisation::ORG_TYPE[grant.recipient.org_type+1][0]
    json.extract! grant.recipient, :name, :charity_number, :company_number,
                                   :organisation_number, :street_address,
                                   :city, :region, :postal_code, :website
    json.operating_for             Grant::OPERATING_FOR[grant.operating_for][0]
    json.income                    Grant::INCOME[grant.income][0]
    json.spending                  Grant::INCOME[grant.spending][0] if grant.spending
    json.employees                 Grant::EMPLOYEES[grant.employees][0]
    json.volunteers                Grant::EMPLOYEES[grant.volunteers][0]
    json.multi_national            grant.recipient.multi_national
  end

  json.beneficiaries do
    json.affect_people grant.affect_people
    json.affect_other  grant.affect_other
    json.genders       grant.gender ? grant.gender : 'None'

    json.ages do
      json.array! grant.ages do |age|
        json.extract! age, :label, :age_from, :age_to
      end
    end

    json.beneficiaries do
      json.array! grant.beneficiaries do |beneficiary|
        json.name beneficiary.sort
        json.extract! beneficiary, :label, :group
      end
    end
  end

  json.locations do
    json.geographic_scale Grant::GEOGRAPHIC_SCALE[grant.geographic_scale][0]
    json.areas_affected do
      json.array! grant.countries do |country|
        json.country country.alpha2
        json.areas   grant.districts.pluck(:name)
      end
    end
  end

end
