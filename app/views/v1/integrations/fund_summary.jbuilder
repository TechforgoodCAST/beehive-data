json.fund_slug params[:fund_slug]
json.period_start period_start
json.period_end period_end

# Overview
json.grant_count @grants.count
json.recipient_count @grants.pluck(:recipient_id).uniq.count

json.amount_awarded_sum    @grants.sum(:amount_awarded).to_f.round(2)
json.amount_awarded_mean   @grants.average(:amount_awarded).to_f.round(2)
json.amount_awarded_median @grants.median(:amount_awarded)
json.amount_awarded_min    @grants.minimum(:amount_awarded).to_f.round(2)
json.amount_awarded_max    @grants.maximum(:amount_awarded).to_f.round(2)
json.amount_awarded_distribution amount_awarded_distribution

if @grants.pluck(:duration_funded_months).include?(nil)
  json.duration_months_mean         "Missing"
  json.duration_months_median       "Missing"
  json.duration_months_min          "Missing"
  json.duration_months_max          "Missing"
  json.duration_months_distribution "Missing"
else
  json.duration_months_mean   @grants.average(:duration_funded_months).to_f.round(2)
  json.duration_months_median @grants.median(:duration_funded_months)
  json.duration_months_min    @grants.minimum(:duration_funded_months).to_f.round(2)
  json.duration_months_max    @grants.maximum(:duration_funded_months).to_f.round(2)
  json.duration_months_distribution duration_months_distribution
end

json.award_month_distribution award_month_distribution

# Recipient
json.org_type_distribution org_type_distribution
json.operating_for_distribution operating_for_distribution
json.income_distribution income_distribution
json.employees_distribution employees_distribution
json.volunteers_distribution volunteers_distribution

# Beneficiary
json.gender_distribution gender_distribution
json.age_group_distribution age_group_distribution
json.beneficiary_distribution beneficiary_distribution

# Location
json.geographic_scale_distribution geographic_scale_distribution
json.country_distribution country_distribution
json.district_distribution district_distribution
