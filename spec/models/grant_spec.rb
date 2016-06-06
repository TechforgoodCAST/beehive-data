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
                        countries: @countries,
                        districts: @uk_districts + @kenya_districts)
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
    expect(@grant.beneficiaries.count).to eq 24
  end

  it 'has many countries' do
    expect(@grant.countries.count).to eq 2
  end

  it 'has many districts' do
    expect(@grant.districts.count).to eq 6
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
      expect(@grant.beneficiaries.count).to eq 4
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

  # TODO: it 'has many activites'

end
