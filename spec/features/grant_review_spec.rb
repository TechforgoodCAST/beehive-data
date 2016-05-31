require 'rails_helper'

describe 'Moderator' do
  before(:each) do
    seed_test_db
    @funder    = create(:funder, country: @countries.first)
    @recipient = create(:approved_org, country: @countries.first)
    @grants    = create_list(:grant, 11, funder: @funder, recipient: @recipient)
    create_and_auth_user
    visit review_grants_path
    expect(current_path).to eq review_grants_path
  end

  scenario 'can manually review grant' do
    expect(page).to have_text 'Import (11)'

    click_on 'Auto-review'
    expect(page).to have_text 'Review (10)'

    # TODO: test UI
    @grants[1].age_groups    = @age_groups
    @grants[1].beneficiaries = @beneficiaries
    @grants[1].countries     = @countries
    @grants[1].districts     = @uk_districts + @kenya_districts

    click_on "#{@grants[1].grant_identifier}"
    expect(current_path).to eq edit_grant_path(@grants[1])

    choose 'All genders' # gender
    within '.grant_affect_people' do
      choose true
    end
    within '.grant_affect_other' do
      choose false
    end
    choose 'Yet to start' # operating_for
    within '.grant_income' do
      choose 'Less than £10k'
    end
    within '.grant_employees' do
      choose 'None'
    end
    within '.grant_volunteers' do
      choose '1 - 5'
    end
    within '.grant_geographic_scale' do
      choose 'One or more local areas'
    end
    click_on 'Save'

    expect(current_path).to eq review_grants_path
    expect(page).to have_text 'Review (9)'
  end

  scenario 'only sees fields for form selection' do
    click_on 'Auto-review'
    click_on "#{@grants[1].grant_identifier}"
    expect(page).to have_css '.hidden', count: 2
    # TODO: test UI
  end

  scenario 'can view approved organisations' do
    @grants.each { |r| r.update_attribute(:state, 'approved') }
    visit grants_path
    expect(page).to have_css '.selectable', count: 11
    click_on @grants.first.grant_identifier
    expect(current_path).to eq edit_grant_path(@grants.first)
  end

  scenario 'can automatically review grant'

end