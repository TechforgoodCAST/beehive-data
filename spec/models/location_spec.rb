require 'rails_helper'

describe Location do
  before(:each) do
    basic_setup
    @location = create(:location, country: @countries.first, grant: @grant)
  end

  it 'is unique per grant' do
    duplicate_location = build(:location, country: @countries.first, grant: @grant)
    expect(duplicate_location).not_to be_valid
  end
end
