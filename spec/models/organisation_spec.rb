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

  it 'has uniqe identifier' do
    duplicate_org = build(:funder,
                          organisation_identifier: @funder.organisation_identifier,
                          country: @country)
    expect(duplicate_org).not_to be_valid
  end

  it 'has unique charity number' do
    duplicate_org = build(:recipient,
                          charity_number: @recipient.charity_number,
                          country: @countries.first)
    expect(duplicate_org).not_to be_valid
  end

  it 'has unique company number' do
    duplicate_org = build(:recipient,
                          company_number: @recipient.company_number,
                          country: @countries.first)
    expect(duplicate_org).not_to be_valid
  end

  it 'has unique organisation number' do
    @recipient.organisation_number = 'ABC123'
    @recipient.save
    duplicate_org = build(:recipient,
                          organisation_number: @recipient.organisation_number,
                          country: @countries.first)
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

  it 'name set from legal name if found'
  it 'company number set if found'
  it 'has a valid company number'
  it 'sets identifier if none present'
  it 'that is individual has appropriate org type'
  it 'geocoded if street address or postal code present'

end
