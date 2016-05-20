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
    expect(@grant.beneficiaries.count).to eq 24
  end

  it 'has many countries' do
    expect(@grant.countries.count).to eq 2
  end

  it 'has many districts' do
    expect(@grant.districts.count).to eq 3
  end

  it 'year set from award date' do
    expect(@grant.year).to eq @grant.award_date.year
  end

  it 'has many activites'
  it 'is valid when imported'
  it 'is valid when in review'
  it 'is valid when approved'
  it 'beneficiaries generated from scrape'

end
