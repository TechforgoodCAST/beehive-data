require 'rails_helper'

describe Country do
  before(:each) do
    seed_test_db
  end

  it 'has many districts' do
    expect(@countries.first.districts).to eq @uk_districts
  end

  it 'is valid' do
    expect(@countries.first).to be_valid
  end
end
