require 'rails_helper'

RSpec.describe District, type: :model do
  before(:each) do
    seed_test_db
  end

  it 'belongs to a country' do
    2.times { |i| expect(@districts[i].country).to eq(@country) }
  end

  it 'is valid' do
    2.times { |i| expect(@districts[i].country).to be_valid }
  end
end
