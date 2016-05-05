Beneficiary.destroy_all
%w[animals buildings disasters].each do |b|
  Beneficiary.create(sort: b)
end

Grant.destroy_all
Grant.create(grant_identifier: 1, funder_identifier: 1, recipient_identifier: 1)
Grant.create(grant_identifier: 2, funder_identifier: 1, recipient_identifier: 2)
Grant.create(grant_identifier: 3, funder_identifier: 1, recipient_identifier: 3)
Grant.create(grant_identifier: 4, funder_identifier: 1, recipient_identifier: 4)
Grant.create(grant_identifier: 5, funder_identifier: 1, recipient_identifier: 5)

Grant.create(grant_identifier: 6, funder_identifier: 2, recipient_identifier: 6)
Grant.create(grant_identifier: 7, funder_identifier: 2, recipient_identifier: 7)
Grant.create(grant_identifier: 8, funder_identifier: 2, recipient_identifier: 8)
Grant.create(grant_identifier: 9, funder_identifier: 2, recipient_identifier: 9)
Grant.create(grant_identifier: 10, funder_identifier: 2, recipient_identifier: 10)

Grant.create(grant_identifier: 11, funder_identifier: 3, recipient_identifier: 11)
Grant.create(grant_identifier: 12, funder_identifier: 3, recipient_identifier: 12)
Grant.create(grant_identifier: 13, funder_identifier: 3, recipient_identifier: 1)
Grant.create(grant_identifier: 14, funder_identifier: 3, recipient_identifier: 2)
Grant.create(grant_identifier: 15, funder_identifier: 3, recipient_identifier: 3)
