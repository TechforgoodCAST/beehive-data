json.array! grants do |grant|
  json.ignore_nil!

  json.extract! grant, :grant_identifier
  json.funder          grant.funder.name
  json.extract! grant, :year, :funding_programme, :title, :description,
                       :currency, :amount_applied_for, :amount_awarded,
                       :amount_disbursed, :award_date, :planned_start_date,
                       :planned_end_date, :open_call

  json.recipient do
    json.extract! grant.recipient, :organisation_identifier
    json.country                   grant.recipient.country.alpha2
    json.organisation_type         Organisation::ORG_TYPE[grant.recipient.org_type+1][0]
    json.extract! grant.recipient, :name, :charity_number, :company_number,
                                   :organisation_number, :street_address,
                                   :city, :region, :postal_code, :latitude,
                                   :longitude, :website
    json.operating_for             Grant::OPERATING_FOR[grant.operating_for][0]
    json.income                    Grant::INCOME[grant.income][0]
    json.spending                  Grant::INCOME[grant.spending][0]
    json.employees                 Grant::EMPLOYEES[grant.employees][0]
    json.volunteers                Grant::EMPLOYEES[grant.volunteers][0]
    json.multi_national            grant.recipient.multi_national
  end

  json.beneficiaries do
    json.age_groups      grant.age_groups.pluck(:label)
    json.genders         grant.gender
    json.beneficiaries do
      json.affect_people grant.affect_people
      json.people        grant.beneficiaries.people.pluck(:label)
      json.affect_other  grant.affect_other
      json.other         grant.beneficiaries.other.pluck(:label)
    end
  end

  json.locations do
    json.geographic_scale Grant::GEOGRAPHIC_SCALE[grant.geographic_scale][0]
    json.countries        grant.countries.pluck(:alpha2)
    if grant.districts.count > 0
      json.districts        grant.districts.pluck(:name)
    end
  end

end
