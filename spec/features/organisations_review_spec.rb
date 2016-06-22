require 'rails_helper'

describe 'Moderator' do
  before(:each) do
    seed_test_db
    @recipients = Array.new(10) do |i|
      create(:recipient, name: "Charity Projects #{i}", country: @countries.first)
    end
    create_and_auth_moderator
  end

  scenario 'cannot scrape' do
    visit review_organisations_path
    expect(page).to_not have_text 'Scrape'
  end

  scenario 'cannot view import column' do
    visit organisations_path
    expect(page).to_not have_text 'Import'
  end

  scenario 'cannot view approved' do
    visit organisations_path
    expect(current_path).to eq review_organisations_path
  end

  scenario 'can manually review organisation' do
    @recipients.each { |r| r.next_step! }

    visit review_organisations_path
    expect(page).to have_text 'Review (10)'

    click_on 'Charity Projects 1'
    expect(current_path).to eq edit_organisation_path(@recipients[1])

    choose true # multi_national
    fill_in 'organisation_postal_code', with: '123 ABC'
    click_on 'Save'
    expect(current_path).to eq review_organisations_path
    expect(page).to have_text 'Review (9)'
  end
end
