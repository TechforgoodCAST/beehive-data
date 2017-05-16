require 'rails_helper'

describe Organisation do
  before(:each) do
    seed_test_db
    @funder    = create(:funder, country: @countries.first)
    @recipient = create(:recipient, country: @countries.first)
    @grants    = Array.new(2) { |i| create(:grant, funder: @funder, recipient: @recipient) }
  end

  it 'belongs to a country' do
    expect(@funder.country.alpha2).to    eq 'GB'
    expect(@recipient.country.alpha2).to eq 'GB'
  end

  it 'has many grants as funder' do
    expect(@funder.grants_as_funder.count).to eq 2
  end

  it 'has many grants as recipient' do
    expect(@recipient.grants_as_recipient.count).to eq 2
  end

  it 'has slug' do
    expect(@funder.slug).to    eq 'esmee-fairbairn-foundation'
    expect(@recipient.slug).to eq 'charity-projects'
  end

  it 'sets slug when name changed' do
    expect(@recipient.slug).to eq 'charity-projects'
    @recipient.name = 'A new slug'
    @recipient.save
    expect(@recipient.slug).to eq 'a-new-slug'
  end

  it 'has uniqe identifier' do
    duplicate_org = build(:funder,
                          organisation_identifier: @funder.organisation_identifier,
                          country: @country)
    expect(duplicate_org).not_to be_valid
  end

  it 'sets registered as truthy if organisational numbers present' do
    expect(@recipient.registered).to eq true
    expect(@funder.registered).to    eq true
  end

  it 'unsets registered if no organiational numbers present' do
    @funder.charity_number = nil
    @funder.save
    expect(@funder.registered).to eq false
  end

  it 'that is charity has appropriate org type' do
    expect(@funder.org_type).to eq 1
  end

  it 'that is company has appropriate org type' do
    @recipient.charity_number = nil
    @recipient.save
    expect(@recipient.org_type).to eq 2
  end

  it 'that is both a charity and company has appropriate org type' do
    expect(@recipient.org_type).to eq 3
  end

  it 'that is another type of organisation has appropriate org type' do
    @recipient.charity_number = nil
    @recipient.company_number = nil
    @recipient.organisation_number = 'ABC123'
    @recipient.save
    expect(@recipient.org_type).to eq 4
  end

  it 'that is unregistered has appropriate org type' do
    @funder.charity_number = nil
    @funder.save
    expect(@funder.org_type).to eq 0
  end

  it 'is valid when imported' do
    expect(@funder).to    be_valid
    expect(@recipient).to be_valid
  end

  it 'is valid when in review' do
    review = create(:review_org, country: @countries.first)
    expect(review).to be_valid
  end

  it 'is valid when approved' do
    approved = create(:approved_org, country: @countries.first)
    expect(approved).to be_valid
  end

  it 'has many users when approved' do
    create_and_auth_admin
    create_and_auth_moderator
    @recipient.update_column(:state, 'approved')
    @recipient.user_ids = [@admin.id, @moderator.id]
    expect(@recipient.users.count).to eq 2
  end

  it 'of org_type "Individual" not automatically set' do
    @recipient.org_type = -1
    @recipient.charity_number = 'ABC123'
    @recipient.company_number = 'ABC123'
    @recipient.organisation_number = 'ABC123'
    @recipient.save
    expect(@recipient.charity_number).to eq nil
    expect(@recipient.company_number).to eq nil
    expect(@recipient.organisation_number).to eq nil
    expect(@recipient.org_type).to eq -1
  end

  it 'of org_type "Another..." not automatically set' do
    @recipient.org_type = 4
    @recipient.charity_number = 'ABC123'
    @recipient.company_number = 'ABC123'
    @recipient.organisation_number = 'ABC123'
    @recipient.save
    expect(@recipient.charity_number).to eq nil
    expect(@recipient.company_number).to eq nil
    expect(@recipient.organisation_number).to eq nil
    expect(@recipient.org_type).to eq 4
  end

  it 'sets identifier if none present'

  it 'with recent_grants_as_funder returns approved grants' do
    expect(@funder.recent_grants_as_funder.count).to eq 0
    @grants.each { |g| g.update_column(:state, 'approved') }
    expect(@funder.recent_grants_as_funder.count).to eq 2
  end

  it 'with recent_grants_as_funder returns grants for last 12 months' do
    @grants.each { |g| g.update_column(:state, 'approved') }
    @grants.first.update_column(:award_date, @grants.first.award_date - 366)
    expect(@funder.recent_grants_as_funder.count).to eq 1
  end

  # TODO: it 'geocoded if street address or postal code present'

end
