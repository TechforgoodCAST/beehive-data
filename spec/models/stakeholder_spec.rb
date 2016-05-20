require 'rails_helper'

describe Stakeholder do
  before(:each) do
    basic_setup
    @stakeholder = create(:stakeholder, beneficiary: @beneficiaries.first, grant: @grant)
  end

  it 'is unique per grant' do
    duplicate_beneficiary = build(:stakeholder, beneficiary: @beneficiaries.first, grant: @grant)
    expect(duplicate_beneficiary).not_to be_valid
  end
end
