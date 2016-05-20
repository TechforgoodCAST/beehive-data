require 'rails_helper'

describe Age do
  before(:each) do
    basic_setup
    @age = create(:age, age_group: @age_groups.first, grant: @grant)
  end

  it 'is unique per grant' do
    duplicate_age_group = build(:age, age_group: @age_groups.first, grant: @grant)
    expect(duplicate_age_group).not_to be_valid
  end
end
