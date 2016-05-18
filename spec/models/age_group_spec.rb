require 'rails_helper'

RSpec.describe AgeGroup, type: :model do
  before(:each) do
    seed_test_db
  end

  it 'is valid' do
    8.times do |i|
      expect(@age_groups[i].label).to    eq(AgeGroup::AGE_GROUPS[i][:label])
      expect(@age_groups[i].age_from).to eq(AgeGroup::AGE_GROUPS[i][:age_from])
      expect(@age_groups[i].age_to).to   eq(AgeGroup::AGE_GROUPS[i][:age_to])
    end
  end

  it 'has 8 records' do
    expect(AgeGroup.all.count).to eq(8)
  end
end
