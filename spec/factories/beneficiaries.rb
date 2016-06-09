FactoryGirl.define do
  factory :beneficiary do
    sequence(:label, (0..24).cycle) do |i|
      Beneficiary::BENEFICIARIES[i][:label]
    end
    sequence(:group, (0..24).cycle) do |i|
      Beneficiary::BENEFICIARIES[i][:group]
    end
    sequence(:sort, (0..24).cycle) do |i|
      Beneficiary::BENEFICIARIES[i][:sort]
    end
  end
end
