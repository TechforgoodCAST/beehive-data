require 'rails_helper'

describe Grant do
  before(:each) do
    seed_test_db
    @funder    = create(:funder, country: @countries.first)
    @recipient = create(:recipient, country: @countries.first)
    @grant     = create(:grant,
                        funder: @funder,
                        recipient: @recipient,
                        age_groups: @age_groups,
                        beneficiaries: @beneficiaries,
                        countries: [@countries.first],
                        districts: @uk_districts)
  end

  it 'belongs to funder' do
    expect(@funder.grants_as_funder.last).to eq @grant
  end

  it 'belongs to recipient' do
    expect(@recipient.grants_as_recipient.last).to eq @grant
  end

  it 'has many age_groups' do
    expect(@grant.age_groups.count).to eq 8
  end

  it 'has many beneficiaries' do
    expect(@grant.beneficiaries.count).to eq 25
  end

  it 'has many countries' do
    @grant.countries = @countries
    @grant.districts = @uk_districts + @kenya_districts
    @grant.save!
    expect(@grant.countries.count).to eq 2
  end

  it 'has many districts' do
    expect(@grant.districts.count).to eq 3
  end

  it 'year set from award date' do
    expect(@grant.year).to eq @grant.award_date.year
  end

  context 'in review' do
    before(:each) do
      @grant.destroy
      @grant = create(:review_grant,
                      funder: @funder,
                      recipient: @recipient,
                      age_groups: @age_groups,
                      beneficiaries: @beneficiaries,
                      countries: [@countries.first],
                      districts: @uk_districts)
    end

    it 'must either affect_people or affect_other' do
      @grant.affect_people = false
      @grant.affect_other  = false
      @grant.save
      expect(@grant.errors.messages[:affect_people]).to eq ['cannot be false if Affect other is false']
      expect(@grant.errors.messages[:affect_other]).to eq ['cannot be false if Affect people is false']
    end

    def set_affect_other
      @grant.affect_people = false
      @grant.affect_other  = true
      expect(@grant).to be_valid
    end

    it 'requires gender if affect_people' do
      @grant.gender = nil
      @grant.save
      expect(@grant.errors.messages[:gender]).to eq ['is not included in the list']

      @grant.beneficiaries = Beneficiary.other
      set_affect_other
    end

    it 'requires age_groups if affect_people' do
      @grant.age_groups = []
      @grant.save
      expect(@grant.errors.messages[:age_groups]).to eq ["can't be blank"]

      @grant.beneficiaries = Beneficiary.other
      set_affect_other
    end

    it "requires beneficiaries group 'People' if affect_people" do
      @grant.beneficiaries = []
      @grant.save
      expect(@grant.errors.messages[:beneficiaries]).to eq ['please select an option']

      @grant.beneficiaries = Beneficiary.other
      set_affect_other
    end

    it "requires beneficiaries group 'Other' if affect_other" do
      @grant.affect_people = false
      @grant.affect_other  = true
      @grant.beneficiaries = Beneficiary.people
      @grant.save
      expect(@grant.errors.messages[:beneficiaries]).to eq ['please select an option']
    end

    it 'clears fields if affect_people' do
      @grant.beneficiaries = Beneficiary.all
      @grant.save!
      expect(@grant.beneficiaries.count).to eq 20
    end

    it 'clears fields if affect_other' do
      @grant.age_groups    = AgeGroup.all
      @grant.beneficiaries = Beneficiary.all
      @grant.affect_people = false
      @grant.affect_other  = true
      @grant.save!
      expect(@grant.gender).to eq nil
      expect(@grant.age_groups.count).to eq 0
      expect(@grant.beneficiaries.count).to eq 5
    end

    it 'districts not required if whole countries selected' do
      @grant.geographic_scale = 2
      @grant.save!
      expect(@grant.districts.count).to eq 0
      expect(@grant).to be_valid
    end

    it 'requires districts to be from selected countries' do
      @grant.districts = @kenya_districts
      @grant.save
      expect(@grant.errors.messages[:districts]).to eq ['not from selected countries']
    end

    it 'is valid when in review' do
      expect(@grant.state).to eq 'review'
      expect(@grant).to be_valid
    end

    it 'is valid when approved' do
      @grant.update_attribute(:state, 'approved')
      expect(@grant.state).to eq 'approved'
      expect(@grant).to be_valid
    end
  end

  it 'is valid when imported' do
    Grant.destroy_all
    grant = create(:grant, funder: @funder, recipient: @recipient)
    expect(@grant.state).to eq 'import'
    expect(grant).to be_valid
  end

  def setup_england
    create(:blank_district, name: 'England', country: @countries.first)
    create(:blank_district, name: 'South East', sub_country: 'England', country: @countries.first)
    create(:blank_district, name: 'East Midlands', sub_country: 'England', country: @countries.first)

    def check_regions(req, res)
      expect(@grant.check_regions(req)).to eq res
    end

    @england         = District.find_by(name: 'England').id
      @south_east    = District.find_by(name: 'South East').id
        @arun        = District.find_by(name: 'Arun').id
        @ashford     = District.find_by(name: 'Ashford').id
      @east_midlands = District.find_by(name: 'East Midlands').id
        @ashfield    = District.find_by(name: 'Ashfield').id
  end

  def setup_wales
    create(:blank_district, name: 'Wales', country: @countries.first)
    create(:blank_district, name: 'Cardiff', sub_country: 'Wales', country: @countries.first)
    @wales     = District.find_by(name: 'Wales').id
      @cardiff = District.find_by(name: 'Cardiff').id
  end

  def setup_regions
    setup_england
    setup_wales
  end

  it 'if all regions for country choose []' do
    setup_england
    check_regions([@south_east, @east_midlands], [])
    expect(@grant.geographic_scale).to eq 2
  end

  it 'districts unaffected if no regions or sub_countries selected' do
    setup_regions
    check_regions([@arun], [@arun])
  end

  it 'if region selected clear districts for region and choose region' do
    setup_regions
    check_regions([@south_east, @arun], [@south_east])
    expect(@grant.geographic_scale).to eq 1
  end

  it 'if all districts for region choose region' do
    setup_regions
    check_regions([@arun, @ashford], [@south_east])
    expect(@grant.geographic_scale).to eq 1
  end

  it 'if all districts for sub_country choose sub_country' do
    setup_regions
    check_regions([@arun, @ashford, @ashfield], [@england])
    expect(@grant.geographic_scale).to eq 1
  end

  it 'if all regions for sub_country choose sub_country' do
    setup_regions
    check_regions([@south_east, @east_midlands], [@england])
    expect(@grant.geographic_scale).to eq 1
  end

  it 'if all districts for country choose []' do
    setup_regions
    check_regions([@arun, @ashford, @ashfield, @cardiff], [])
    expect(@grant.geographic_scale).to eq 2
  end

  it 'if all regions or sub_countries for country choose []' do
    setup_regions
    check_regions([@south_east, @east_midlands, @wales], [])
    expect(@grant.geographic_scale).to eq 2
  end

  it 'if all sub_countries for country choose []' do
    setup_regions
    check_regions([@england, @wales], [])
    expect(@grant.geographic_scale).to eq 2
  end

  it 'sets geographic_scale to 0'
  it 'sets geographic_scale to 3 if more than one country'

end
