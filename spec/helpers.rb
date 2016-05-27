module Helpers

  def seed_test_db
    @age_groups      = create_list(:age_group, AgeGroup::AGE_GROUPS.count)
    @beneficiaries   = create_list(:beneficiary, Beneficiary::BENEFICIARIES.count)
    @countries       = Array.new(2) { |i| create(:country) }
    @uk_districts    = Array.new(3) { |i| create(:district, country: @countries.first) }
    @kenya_districts = Array.new(3) { |i| create(:kenya_district, country: @countries.last) }
  end

  def basic_setup
    seed_test_db
    @funder    = create(:funder, country: @countries.first)
    @recipient = create(:recipient, country: @countries.first)
    @grant     = create(:grant, funder: @funder, recipient: @recipient)
  end

  def json
    JSON.parse(response.body)
  end

  def request(endpoint)
    get endpoint, {}, { 'Accept' => Mime::JSON }
  end

  def auth_request(endpoint, user)
    get endpoint, {}, { 'Authorization': "Token token=#{user.api_token}" }
  end

  def create_and_auth_user(opts={})
    @user = create(:user)
    login_as(@user, scope: :user)
  end

end
