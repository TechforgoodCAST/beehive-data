require 'rails_helper'

describe Beneficiary do
  before(:each) do
    seed_test_db
  end

  it 'is valid' do
    24.times do |i|
      %w[label group sort].each do |field|
        expect(@beneficiaries[i][field]).to eq Beneficiary::BENEFICIARIES[i][field.to_sym]
      end
    end
  end

  it 'has 24 records' do
    expect(Beneficiary.all.count).to eq 24
  end
end
