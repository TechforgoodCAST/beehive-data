require 'rails_helper'

RSpec.describe AgeGroup, type: :model do
  before(:each) do
    seed_test_db
  end

  it 'is valid' do
    8.times do |i|
      %w[label age_from age_to].each do |field|
        expect(@age_groups[i][field]).to eq(AgeGroup::AGE_GROUPS[i][field.to_sym])
      end
    end
  end

  it 'has 8 records' do
    expect(AgeGroup.all.count).to eq(8)
  end
end
