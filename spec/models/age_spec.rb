require 'rails_helper'

RSpec.describe Age, type: :model do
  before(:each) do
    basic_setup
    @age = create(:age, age_group: @age_groups[0], grant: @grant)
  end

  it 'is unique per grant' do
    duplicate_age_group = build(:age, age_group: @age_groups[0], grant: @grant)
    expect(duplicate_age_group).not_to be_valid
  end
end
