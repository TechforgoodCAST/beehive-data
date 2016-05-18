require 'rails_helper'

RSpec.describe Country, type: :model do
  before(:each) do
    seed_test_db
  end

  it 'has many districts' do
    expect(@countries[0].districts).to eq(@uk_districts)
  end

  it 'is valid' do
    expect(@countries[0]).to be_valid
  end
end
