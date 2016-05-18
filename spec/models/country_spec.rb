require 'rails_helper'

RSpec.describe Country, type: :model do
  before(:each) do
    seed_test_db
  end

  it 'has many districts' do
    expect(@country.districts).to eq(@districts)
  end

  it 'is valid' do
    expect(@country).to be_valid
  end
end
