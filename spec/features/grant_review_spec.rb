require 'rails_helper'

describe 'Moderator' do
  before(:each) do
    seed_test_db
    @funder    = create(:funder, country: @countries.first)
    @recipient = create(:recipient, country: @countries.first)
    @grants    = create_list(:grant, 11, funder: @funder, recipient: @recipient)
    create_and_auth_user
    visit review_grants_path
    expect(current_path).to eq review_grants_path
  end

  scenario 'can manually review grant' do
    expect(page).to have_text 'Import (11)'

    click_on 'Auto-review'
    expect(page).to have_text 'Review (10)'

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

  scenario 'can automatically review grant'

end
