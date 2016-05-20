require 'rails_helper'

describe District do
  before(:each) do
    seed_test_db
  end

  it 'belongs to a country' do
    3.times { |i| expect(@uk_districts[i].country).to eq @countries.first }
  end

  it 'is valid' do
    3.times { |i| expect(@uk_districts[i].country).to be_valid }
  end
end
