json.array! @grants do |grant|

  json.ignore_nil!

  json.recipient  grant.recipient.slug
  json.fund_slug  grant.fund_slug

  categories = Beneficiary::BENEFICIARIES.map { |b| b[:sort] }
  beneficiaries = grant.beneficiaries.pluck(:sort)
  categories.each do |sort|
    json.set! sort, beneficiaries.include?(sort) ? 1 : 0
  end

end
