json.array! @funders do |funder|
  json.ignore_nil!
  json.extract! funder, :organisation_identifier, :charity_number,
                        :company_number, :organisation_number, :name,
                        :street_address, :city, :region, :postal_code, :website,
                        :legal_name, :company_type, :multi_national,
                        :registered, :latitude, :longitude
  json.country funder.country.alpha2
  json.organisation_type Organisation::ORG_TYPE[funder.org_type+1][0]
end
