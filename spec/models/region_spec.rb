require 'rails_helper'

describe Region do
  before(:each) do
    seed_test_db
    @funder    = create(:funder, country: @countries.first)
    @recipient = create(:recipient, country: @countries.first)
    @grant     = create(:grant, funder: @funder, recipient: @recipient, countries: [@countries.first])
    @uk_region = create(:region, district: @uk_districts.first, grant: @grant)
  end

  it 'is unique per grant' do
    duplicate_region = build(:region, district: @uk_districts.first, grant: @grant)
    expect(duplicate_region).not_to be_valid
  end

  it 'only districts for grant countries are valid' do
    kenya_district = create(:kenya_districts, country: @countries.last)
    kenya_region   = build(:region, district: kenya_district, grant: @grant)
    expect(kenya_region).not_to be_valid
    expect(@uk_region).to be_valid
  end
end
