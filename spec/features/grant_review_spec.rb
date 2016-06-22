require 'rails_helper'

describe 'Moderator' do
  before(:each) do
    seed_test_db
    @funder    = create(:funder, country: @countries.first)
    @recipient = create(:approved_org, country: @countries.first)
    @grants    = create_list(:grant, 10, funder: @funder, recipient: @recipient)
    create_and_auth_moderator
  end

  scenario 'cannot auto-review' do
    visit review_grants_path
    expect(page).to_not have_text 'Auto-review'
  end

  scenario 'cannot view import column' do
    visit grants_path
    expect(page).to_not have_text 'Import'
  end

  scenario 'cannot view approved' do
    visit grants_path
    expect(current_path).to eq review_grants_path
  end

  scenario 'can manually review grant' do
    @grants.each { |g| g.next_step! }

    visit review_grants_path
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
    click_on 'Save'

    expect(current_path).to eq review_grants_path
    expect(page).to have_text 'Review (9)'
  end

  scenario 'only sees fields for form selection' do
    @grants.first.next_step!
    visit review_grants_path
    click_on "#{@grants.first.grant_identifier}"
    expect(page).to have_css '.hidden', count: 2
    # TODO: test UI
  end

  scenario 'validated at correct geographic_scale'
  scenario 'geographic_scale set by import'

  # TODO: scenario 'can automatically review grant'

end
