require 'rails_helper'

describe 'Integration' do
  before(:each) do
    seed_test_db
    @recipient = create(:approved_org, country: @countries.first)
    @funder    = create(:approved_org, country: @countries.first,
                         publisher: true
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
    @beneficiaries = '/v1/integrations/beneficiaries'
    @amounts = '/v1/integrations/amounts'
    @durations = '/v1/integrations/durations'
    @fund_summary = "/v1/integrations/fund_summary/#{@grants.first.fund_slug}"
  end

  it 'with Beehive Insight: routes to correct version' do
    assert_generates @beneficiaries, { controller: 'v1/integrations', action: 'beneficiaries' }
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

      it 'returns all grants' do
        @grants.first.update_attribute(:state, 'import')
        auth_request(@beneficiaries, @admin)
        expect(json.length).to eq 3
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
          sources fund_slug period_start period_end grant_count recipient_count
          amount_awarded_sum amount_awarded_mean amount_awarded_median
          amount_awarded_min amount_awarded_max amount_awarded_distribution
          duration_awarded_months_mean duration_awarded_months_median
          duration_awarded_months_min duration_awarded_months_max
          duration_awarded_months_distribution award_month_distribution
          org_type_distribution operating_for_distribution income_distribution
          employees_distribution volunteers_distribution gender_distribution
          age_group_distribution beneficiary_distribution
          geographic_scale_distribution country_distribution
          district_distribution grant_examples
        ].each do |f|
          expect(json).to have_key(f)
        end
      end

      it 'amount_awarded_distribution has correct structure' do
        result = [
          { "start" => 0, "end" => 49, "segment" => 0, "percent" => 0, "count" => 0 },
          { "start" => 50, "end" => 299, "segment" => 1, "percent" => 0, "count" => 0 },
          { "start" => 300, "end" => 749, "segment" => 2, "percent" => 0, "count" => 0 },
          { "start" => 750, "end" => 1_499, "segment" => 3, "percent" => 0, "count" => 0 },
          { "start" => 1_500, "end" => 3_499, "segment" => 4, "percent" => 0, "count" => 0 },
          { "start" => 3_500, "end" => 7_499, "segment" => 5, "percent" => 0, "count" => 0 },
          { "start" => 7_500, "end" => 12_499, "segment" => 6, "percent" => 0, "count" => 0 },
          { "start" => 12_500, "end" => 17_499, "segment" => 7, "percent" => 0, "count" => 0 },
          { "start" => 17_500, "end" => 27_499, "segment" => 8, "percent" => 0, "count" => 0 },
          { "start" => 27_500, "end" => 34_999, "segment" => 9, "percent" => 0, "count" => 0 },
          { "start" => 35_000, "end" => 44_999, "segment" => 10, "percent" => 1, "count" => 3 },
          { "start" => 45_000, "end" => 74_999, "segment" => 11, "percent" => 0, "count" => 0 },
          { "start" => 75_000, "end" => 299_999, "segment" => 12, "percent" => 0, "count" => 0 },
          { "start" => 300_000, "end" => 5_249_999, "segment" => 13, "percent" => 0, "count" => 0 },
          { "start" => 5_250_000, "end" => 9_007_199_254_740_991, "segment" => 14, "percent" => 0, "count" => 0 }
        ]
        expect(json['amount_awarded_distribution']).to eq result
      end
    end
  end

end
