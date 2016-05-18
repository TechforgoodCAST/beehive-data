require 'rails_helper'

RSpec.describe Location, type: :model do
  before(:each) do
    basic_setup
    @location = create(:location, country: @countries[0], grant: @grant)
  end

  it 'is unique per grant' do
    duplicate_location = build(:location, country: @countries[0], grant: @grant)
    expect(duplicate_location).not_to be_valid
  end
end
