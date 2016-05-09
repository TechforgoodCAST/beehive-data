require 'rails_helper'

RSpec.describe District, type: :model do
  it 'is valid' do
    country = FactoryGirl.create(:country)
    district = FactoryGirl.create(:district, country: country)
    expect(district.country).to be_valid
  end
end
