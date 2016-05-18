require 'rails_helper'

RSpec.describe Region, type: :model do
  before(:each) do
    seed_test_db
    @funder    = create(:funder, country: @countries[0])
    @recipient = create(:recipient, country: @countries[0])
    @grant     = create(:grant, funder: @funder, recipient: @recipient, countries: [@countries[0]])
    @uk_region = create(:region, district: @uk_districts[0], grant: @grant)
  end

  it 'is unique per grant' do
    duplicate_region = build(:region, district: @uk_districts[0], grant: @grant)
    expect(duplicate_region).not_to be_valid
  end

  it 'only districts for grant countries are valid' do
    kenya_district = create(:kenya_districts, country: @countries[1])
    kenya_region   = build(:region, district: kenya_district, grant: @grant)
    expect(kenya_region).not_to be_valid
    expect(@uk_region).to be_valid
  end
end
