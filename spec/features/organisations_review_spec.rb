require 'rails_helper'

describe 'Moderator' do
  before(:each) do
    seed_test_db
    @recipients = Array.new(11) do |i|
      create(:recipient, name: "Charity Projects #{i}", country: @countries.first)
    end
    create_and_auth_user
    visit review_organisations_path
    expect(current_path).to eq review_organisations_path
  end

  scenario 'can manually review organisation' do
    expect(page).to have_text 'Import (11)'

    click_on 'Scrape 10 organisations'
    expect(page).to have_text 'Review (10)'

    click_on 'Charity Projects 1'
    expect(current_path).to eq edit_organisation_path(@recipients[1])

    select true # multi_national
    fill_in 'organisation_postal_code', with: '123 ABC'
    click_on 'Save'
    expect(current_path).to eq review_organisations_path
    expect(page).to have_text 'Review (9)'
  end

  scenario 'can automatically review organistion'

end
