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
    @beneficiaries = '/v1/insight/grants'
    @amounts = '/v1/integrations/amounts'
    @durations = '/v1/integrations/durations'
    @fund_summary = "/v1/integrations/fund_summary/#{@grants.first.fund_slug}"
  end

  it 'with Beehive Insight: routes to correct version' do
    assert_generates @beneficiaries, { controller: 'v1/integrations', action: 'insight_grants' }
    assert_generates @amounts, { controller: 'v1/integrations', action: 'amounts' }
    assert_generates @durations, { controller: 'v1/integrations', action: 'durations' }
    assert_generates @fund_summary, { controller: 'v1/integrations', action: 'fund_summary', fund_slug: @grants.first.fund_slug }
  end

  context 'beneficiaries' do
    it 'moderator unauthorised' do
      auth_request(@beneficiaries, @user)
      expect(response).to be_unauthorized
    end

    context 'admin' do
      before(:each) do
        auth_request(@beneficiaries, @admin)
      end

      it 'authorised' do
        expect(response).to be_success
      end

      it 'returns a list of grants' do
        expect(json.length).to eq 3
      end

      it 'returns a only approved grants' do
        @grants.first.update_attribute(:state, 'import')
        auth_request(@beneficiaries, @admin)
        expect(json.length).to eq 2
      end

      it 'correct structure' do
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
  end

  context 'amounts' do
    it 'moderator unauthorised' do
      auth_request(@amounts, @user)
      expect(response).to be_unauthorized
    end

    context 'admin' do
      before(:each) do
        auth_request(@amounts, @admin)
      end

      it 'authorised' do
        expect(response).to be_success
      end

      it 'returns a list of funds' do
        @grants.last.update_column(:fund_slug, 'new_fund_slug')
        auth_request(@amounts, @admin)
        expect(json.length).to eq 2
      end

      it 'correct structure' do
        %w[fund_slug amounts].each do |f|
          expect(json.first).to have_key(f)
        end
        expect(json.first['amounts']).to eq [40000.0, 40000.0, 40000.0]
      end
    end
  end

  context 'durations' do
    it 'moderator unauthorised' do
      auth_request(@durations, @user)
      expect(response).to be_unauthorized
    end

    context 'admin' do
      before(:each) do
        auth_request(@durations, @admin)
      end

      it 'authorised' do
        expect(response).to be_success
      end

      it 'returns a list of funds' do
        @grants.last.update_column(:fund_slug, 'new_fund_slug')
        auth_request(@amounts, @admin)
        expect(json.length).to eq 2
      end

      it 'correct structure' do
        %w[fund_slug durations].each do |f|
          expect(json.first).to have_key(f)
        end
        expect(json.first['durations']).to eq [12.0, 12.0, 12.0]
      end
    end
  end

  context 'fund_summary' do
    it 'moderator unauthorised' do
      auth_request(@fund_summary, @user)
      expect(response).to be_unauthorized
    end

    context 'admin' do
      before(:each) do
        auth_request(@fund_summary, @admin)
      end

      it 'authorised' do
        expect(response).to be_success
      end

      it 'correct structure' do
        %w[
          fund_slug period_start period_end grant_count recipient_count
          amount_awarded_sum amount_awarded_mean amount_awarded_median
          amount_awarded_min amount_awarded_max amount_awarded_distribution
          duration_months_mean duration_months_median duration_months_min
          duration_months_max duration_months_distribution
          award_month_distribution org_type_distribution
          operating_for_distribution income_distribution employees_distribution
          volunteers_distribution gender_distribution age_group_distribution
          beneficiary_distribution geographic_scale_distribution
          country_distribution district_distribution
        ].each do |f|
          expect(json).to have_key(f)
        end
      end
    end
  end

end
