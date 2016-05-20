require 'csv'

if ENV['SAVE']
  AgeGroup.destroy_all
  AgeGroup::AGE_GROUPS.each do |hash|
    AgeGroup.create! hash
  end

  Beneficiary.destroy_all
  Beneficiary::BENEFICIARIES.each do |hash|
    Beneficiary.create! hash
  end

  Country.destroy_all
  CSV.foreach(Rails.root.join('app', 'assets', 'csv', 'countries.csv'), headers: true) do |row|
    Country.create! row.to_hash
  end

  District.destroy_all
  CSV.foreach(Rails.root.join('app', 'assets', 'csv', 'districts.csv'), headers: true) do |row|
    data = row.to_hash
    data['country'] = Country.find_by_alpha2(row['alpha2'])
    District.create! data.except('alpha2')
  end
else
  puts "NOT SAVED: Please use rake 'db:seed SAVE=true'. IMPORTANT: This is a destructive action and will invalidate exisiting associations."
end

Organisation.where(organisation_identifier: 'GB-CHC-200051').destroy_all
Organisation.create!(
  organisation_identifier: 'GB-CHC-200051',
  charity_number:          '200051',
  name:                    'Esmee Fairbairn Foundation',
  country:                 Country.find_by_alpha2('GB'),
  publisher:               true
)
Organisation.where(organisation_identifier: 'GB-CHC-327114').destroy_all
Organisation.create!(
  organisation_identifier: 'GB-CHC-327114',
  charity_number:          '327114',
  name:                    'Lloyds Bank Foundation for England and Wales',
  country:                 Country.find_by_alpha2('GB'),
  publisher:               true
)
