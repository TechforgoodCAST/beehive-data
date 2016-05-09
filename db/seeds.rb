Beneficiary.destroy_all
%w[animals buildings disasters].each do |b|
  Beneficiary.create(sort: b)
end

Organisation.destroy_all
@funder = Organisation.create(organisation_identifier: 'GB-CHC-000', name: 'Funder', publisher: true)
@recipient = Organisation.create(organisation_identifier: 'GB-CHC-111', name: 'Recipient')

Grant.destroy_all
Grant.create(grant_identifier: '360-1', funder: @funder, recipient: @recipient)
Grant.create(grant_identifier: '360-2', funder: @funder, recipient: @recipient)
Grant.create(grant_identifier: '360-3', funder: @funder, recipient: @recipient)
