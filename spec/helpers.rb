module Helpers
  def seed_test_db
    @age_groups    = create_list(:age_group, AgeGroup::AGE_GROUPS.count)
    @beneficiaries = create_list(:beneficiary, Beneficiary::BENEFICIARIES.count)
    @country  = create(:country)
    @districts = Array.new(2) { |i| create(:district, country: @country) }
  end
end
