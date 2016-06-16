require 'rails_helper'

describe '/v1/demo/grants/(:year)' do
  before(:each) do
    seed_test_db
    @recipient = create(:approved_org, country: @countries.first)
    @funder    = create(:approved_org, country: @countries.first,
                         publisher: true,
                         license: 'http://some.license/'
                       )
    @grants = create_list(:approved_grant, 3,
                            funder: @funder,
                            recipients: [@recipient],
                            age_groups: @age_groups,
                            beneficiaries: @beneficiaries,
                            countries: @countries,
                            districts: @uk_districts + @kenya_districts
                          )
    @user = create(:user)
    @year = 2015
    @endpoint = "/v1/demo/grants/#{@year}"
    request(@endpoint)
  end

  it 'does not require authentication' do
    expect(response).not_to be_unauthorized
  end

  it 'routes to correct version' do
    assert_generates @endpoint, { controller: 'v1/examples', action: 'grants_by_year', year: @year }
  end

  it 'sends a list of grants' do
    expect(response).to be_success
    expect(json.length).to eq 3
  end

  it 'only sends grants for given year' do
    @grants.first.update_attribute(:award_year, @year-1)
    request(@endpoint)
    expect(json.length).to eq 2
  end

  it 'only sends approved grants' do
    @grants.first.update_attribute(:state, 'import')
    request(@endpoint)
    expect(json.length).to eq 2
  end

  it 'shows appropriate basic values' do
    %w[id funder_id recipient_id state created_at updated_at].each do |f|
      expect(json.first).not_to have_key(f)
    end
    %w[
      publisher license grant_identifier funder award_year title description
      currency amount_awarded award_date recipients beneficiaries locations
    ].each do |f|
      expect(json.first).to have_key(f)
    end
  end

  it 'shows appropriate recipient values' do
    %w[
      organisation_identifier country postal_code operating_for income
      employees volunteers multi_national
    ].each do |f|
      expect(json.first['recipients'].first).to have_key(f)
    end
  end

  it 'shows appropriate beneficiaries values' do
    %w[affect_people affect_other genders ages beneficiaries].each do |f|
      expect(json.first['beneficiaries']).to have_key(f)
    end
    %w[label age_from age_to].each do |f|
      expect(json.first['beneficiaries']['ages'].first).to have_key(f)
    end
    %w[name label group].each do |f|
      expect(json.first['beneficiaries']['beneficiaries'].first).to have_key(f)
    end
  end

  it 'shows appropriate locations values' do
    %w[geographic_scale areas_affected].each do |f|
      expect(json.first['locations']).to have_key(f)
    end
    %w[country areas].each do |f|
      expect(json.first['locations']['areas_affected'].first).to have_key(f)
    end
  end

  it 'does not include null values' do
    expect(json.first['recipients'].first).to have_key('company_number')
    @recipient.update_column(:company_number, nil)
    request(@endpoint)
    expect(json.first['recipients'].first).not_to have_key('company_number')
  end

  it "only show 'All ages' option when selected" do
    all_ages_option = { 'label' => 'All ages', 'age_from' => 0, 'age_to' => 150 }
    expect(json.first['beneficiaries']['ages'].count).to eq 1
    expect(json.first['beneficiaries']['ages'].first).to eq all_ages_option

    @grants[0].age_group_ids = AgeGroup.pluck(:id).slice(1, AgeGroup.count)
    @grants[0].save!
    request(@endpoint)
    expect(@grants[0].age_groups.count).to eq 7
    expect(json.first['beneficiaries']['ages'].count).to eq AgeGroup.count-1
  end

  it 'shows [] if entire country affected' do
    @grants.first.countries = [@countries.first]
    @grants.first.save!
    request(@endpoint)
    expect(json.last['locations']['areas_affected'].count).to eq 1
    expect(json.last['locations']['geographic_scale']).to eq 'An entire country'
    expect(json.last['locations']['areas_affected'].first['areas']).to eq []
  end

  it 'shows [] if multiple countries affected' do
    expect(json.first['locations']['areas_affected'].count).to eq 2
    expect(json.first['locations']['geographic_scale']).to eq 'Across many countries'
    expect(json.first['locations']['areas_affected'].first['areas']).to eq []
  end

end
