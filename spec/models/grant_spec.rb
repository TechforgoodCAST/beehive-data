require 'rails_helper'

RSpec.describe Grant, type: :model do
  before(:each) do
    seed_test_db
    @funder    = create(:funder, country: @country)
    @recipient = create(:recipient, country: @country)
    @grant     = create(:grants,
                        funder: @funder,
                        recipient: @recipient,
                        age_groups: @age_groups,
                        beneficiaries: @beneficiaries,
                        countries: [@country, @country],
                        districts: @districts)
  end

  it 'belongs to funder' do
    expect(@funder.grants_as_funder.last).to eq(@grant)
  end

  it 'belongs to recipient' do
    expect(@recipient.grants_as_recipient.last).to eq(@grant)
  end

  it 'has many age_groups' do
    expect(@grant.age_groups.count).to eq(8)
  end

  it 'has many beneficiaries' do
    expect(@grant.beneficiaries.count).to eq(24)
  end

  it 'has many countries' do
    expect(@grant.countries.count).to eq(2)
  end
  # it 'has many districts'
  # it 'has many activites'
  # it 'is valid when imported'
  # it 'is valid when in review'
  # it 'is valid when approved'
  # it 'beneficiaries generated from scrape'
end
