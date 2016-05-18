require 'rails_helper'

RSpec.describe Stakeholder, type: :model do
  before(:each) do
    basic_setup
    @stakeholder = create(:stakeholder, beneficiary: @beneficiaries[0], grant: @grant)
  end

  it 'is unique per grant' do
    duplicate_beneficiary = build(:stakeholder, beneficiary: @beneficiaries[0], grant: @grant)
    expect(duplicate_beneficiary).not_to be_valid
  end
end
