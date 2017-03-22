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
  CSV.foreach(Rails.root.join('lib', 'assets', 'csv', 'countries.csv'), headers: true) do |row|
    data = row.to_hash
    data["alt_names"] = (data["altnames"] || "").split(",")
    Country.create! data
  end

  District.destroy_all
  CSV.foreach(Rails.root.join('lib', 'assets', 'csv', 'districts.csv'), headers: true) do |row|
    data = row.to_hash
    data['country'] = Country.find_by_alpha2(row['alpha2'])
    District.create! data.except('alpha2')
  end
else
  puts "NOT SAVED: Please use rake 'db:seed SAVE=true'. IMPORTANT: This is a destructive action and will invalidate exisiting associations."
end
