require 'rails_helper'

describe 'Integration' do
  before(:each) do
    seed_test_db
    @recipient = create(:approved_org, country: @countries.first)
    @funder    = create(:approved_org, country: @countries.first,
                         publisher: true,
                         license: 'http://some.license/'
                       )
    @grants = create_list(:approved_grant, 3,
                            funder: @funder,
                            recipient: @recipient,
                            age_groups: @age_groups,
                            beneficiaries: @beneficiaries,
                            countries: @countries,
                            districts: @uk_districts + @kenya_districts
                          )
    @admin = create(:admin_user)
    @user  = create(:user)
    @endpoint = '/v1/insight/grants'
  end

  it 'with Beehive Insight: routes to correct version' do
    assert_generates @endpoint, { controller: 'v1/integrations', action: 'insight_grants' }
  end

  context 'admin' do
    before(:each) do
      auth_request(@endpoint, @admin)
    end

    it 'with Beehive Insight: admin api token is authorised' do
      expect(response).to be_success
    end

    it 'with Beehive Insight: sends a list of grants' do
      expect(json.length).to eq 3
    end

    it 'with Beehive Insight: only sends approved grants' do
      @grants.first.update_attribute(:state, 'import')
      auth_request(@endpoint, @admin)
      expect(json.length).to eq 2
    end

    it 'with Beehive Insight: renders appropriate json structure' do
      %w[
        recipient fund_slug public crime relationship disabilities religious
        disasters education unemployed ethnic water food housing animals
        buildings mental orientation environment physical organisation
        organisations poverty refugees services care exploitation
      ].each do |f|
        expect(json.first).to have_key(f)
      end
    end
  end

  context 'moderator' do
    before(:each) do
      auth_request(@endpoint, @user)
    end

    it 'with Beehive Insight: moderator api token is not authorised' do
      expect(response).to be_unauthorized
    end
  end

end
