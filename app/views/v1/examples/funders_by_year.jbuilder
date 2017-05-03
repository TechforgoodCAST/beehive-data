json.array! @funders do |funder|
  json.ignore_nil!

  json.award_year        params[:year]
  json.extract! funder,  :name, :organisation_identifier, :charity_number,
                         :company_number, :organisation_number,
                         :street_address, :city, :region, :postal_code, :website,
                         :company_type, :multi_national, :registered,
                         :latitude, :longitude
  json.country           funder.country.alpha2
  json.organisation_type Organisation::ORG_TYPE[funder.org_type+1][0]

  grants = funder.grants_as_funder
  json.summary do
    json.grant_count          grants.count
    json.currency             grants.pluck(:currency).uniq.first
    json.total_amount_awarded grants.sum(:amount_awarded)
    json.min_amount_awarded   grants.minimum(:amount_awarded)
    json.avg_amount_awarded   grants.average(:amount_awarded).present? ? grants.average(:amount_awarded).round(2) : 0
    json.max_amount_awarded   grants.maximum(:amount_awarded)
    json.funding_programmes   grants.pluck(:funding_programme).uniq
  end

  json.data_quality do
    json.normal (grants.where('state != ?', 'approved').count / grants.count.to_f).round(2)
    json.high   (grants.approved.count.to_f / grants.count.to_f).round(2)
  end
end
