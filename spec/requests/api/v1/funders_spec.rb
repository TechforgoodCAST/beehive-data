require 'rails_helper'

describe '/funders' do
  before(:each) do
    seed_test_db
    @funders  = create_list(:approved_org, 3,
                              country: @countries.first,
                              publisher: true
                            )
    @user = create(:user)
    @endpoint = '/v1/funders'
    auth_request(@endpoint, @user)
  end

  it 'requires authentication' do
    request(@endpoint)
    expect(response).to be_unauthorized
  end

  it 'routes to correct version' do
    assert_generates @endpoint, { controller: 'v1/funders', action: 'index' }
  end

  it 'sends a list of funders' do
    expect(response).to be_success
    expect(json.length).to eq 3
  end

  it 'only sends funders' do
    @funders.first.update_attribute(:publisher, false)
    auth_request(@endpoint, @user)
    expect(json.length).to eq 2
  end

  it 'only sends approved funders' do
    @funders.first.update_attribute(:state, 'import')
    auth_request(@endpoint, @user)
    expect(json.length).to eq 2
  end

  it 'shows appropriate values' do
    %w[id country_id state publisher created_at updated_at scraped_at].each do |f|
      expect(json.first).not_to have_key(f)
    end
  end

  it 'does not include null values' do
    expect(json.first).not_to have_key('organisation_number')
  end

  it 'shows country alpha2' do
    expect(json.first['country']).to eq 'GB'
  end

  it 'shows org_type string' do
    expect(json.first['organisation_type']).to eq 'A registered charity & company'
  end
end
