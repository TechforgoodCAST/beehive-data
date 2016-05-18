module Helpers

  def seed_test_db
    @age_groups    = create_list(:age_group, AgeGroup::AGE_GROUPS.count)
    @beneficiaries = create_list(:beneficiary, Beneficiary::BENEFICIARIES.count)
    @countries     = Array.new(2) { |i| create(:country) }
    @uk_districts  = Array.new(3) { |i| create(:district, country: @countries[0]) }
  end

  def basic_setup
    seed_test_db
    @funder    = create(:funder, country: @countries[0])
    @recipient = create(:recipient, country: @countries[0])
    @grant     = create(:grant, funder: @funder, recipient: @recipient)
  end

end
