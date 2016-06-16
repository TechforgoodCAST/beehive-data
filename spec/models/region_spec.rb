require 'rails_helper'

describe Region do
  before(:each) do
    seed_test_db
    @funder     = create(:funder, country: @countries.first)
    @recipients = [create(:recipient, country: @countries.first)]
    @grant      = create(:grant, funder: @funder, recipients: @recipients, countries: [@countries.first])
    @uk_region  = create(:region, district: @uk_districts.first, grant: @grant)
  end

  it 'is unique per grant' do
    duplicate_region = build(:region, district: @uk_districts.first, grant: @grant)
    expect(duplicate_region).not_to be_valid
  end
end
