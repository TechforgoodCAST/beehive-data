require 'rails_helper'

RSpec.describe District, type: :model do
  before(:each) do
    seed_test_db
  end

  it 'belongs to a country' do
    3.times { |i| expect(@uk_districts[i].country).to eq(@countries[0]) }
  end

  it 'is valid' do
    3.times { |i| expect(@uk_districts[i].country).to be_valid }
  end
end
