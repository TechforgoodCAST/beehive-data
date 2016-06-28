require 'rails_helper'

describe 'Admin' do
  context 'Organisation' do
    before(:each) do
      seed_test_db
      @recipients = Array.new(11) do |i|
        create(:recipient, name: "Charity Projects #{i}", country: @countries.first)
      end
      create_and_auth_admin
    end

    scenario 'can scrape and review organisation' do
      visit review_organisations_path
      expect(page).to have_text 'Import (11)'

      click_on 'Scrape'
      expect(page).to have_text 'Review (10)'

      click_on 'Charity Projects 1'
      expect(current_path).to eq edit_organisation_path(@recipients[1])

      choose true # multi_national
      fill_in 'organisation_postal_code', with: '123 ABC'
      click_on 'Save'
      expect(current_path).to eq review_organisations_path
      expect(page).to have_text 'Review (9)'

      visit organisations_path
      expect(page).to have_text @admin.initials
    end

    scenario 'can specify number of organisations to scrape' do
      visit review_organisations_path
      expect(page).to have_text 'Import (11)'

      fill_in 'review', with: '1'
      click_on 'Scrape'
      expect(page).to have_text 'Review (1)'
    end

    scenario 'can view approved organisations' do
      @recipients.each { |r| r.update_attribute(:state, 'approved') }
      visit organisations_path
      expect(page).to have_css '.selectable', count: 11
      click_on @recipients.first.name
      expect(current_path).to eq edit_organisation_path(@recipients.first)
    end
  end

  context 'Grant' do
    before(:each) do
      seed_test_db
      @funder    = create(:funder, country: @countries.first)
      @recipient = create(:approved_org, country: @countries.first)
      @grants    = create_list(:grant, 11, funder: @funder, recipient: @recipient)
      create_and_auth_admin
    end

    scenario 'can scrape and review grant' do
      visit review_grants_path
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
      click_on 'Save'

      expect(current_path).to eq review_grants_path
      expect(page).to have_text 'Review (9)'

      visit grants_path
      expect(page).to have_text @admin.initials
    end

    scenario 'can specify number of grants to auto-review' do
      visit review_grants_path
      expect(page).to have_text 'Import (11)'

      fill_in 'review', with: '1'
      click_on 'Auto-review'
      expect(page).to have_text 'Review (1)'
    end

    scenario 'can view approved organisations' do
      @grants.each { |r| r.update_attribute(:state, 'approved') }
      visit grants_path
      expect(page).to have_css '.selectable', count: 11
      click_on @grants.first.grant_identifier
      expect(current_path).to eq edit_grant_path(@grants.first)
    end
  end

  scenario 'approves many organisations'
  scenario 'shares approval with other moderators'
  scenario 'scraped org has moderator'
end
