require 'rails_helper'

describe 'Public Site' do
  before(:each) do
    visit root_path
  end

  scenario 'can visit home page' do
    expect(page).to have_text 'High quality data about charitable funding'
  end

  scenario 'can navigate to examples' do
    click_link('Examples')
    expect(page).to have_text 'Examples'
  end

  scenario 'can navigate to docs' do
    expect(page).to have_selector "a[href='http://beehive-data.api-docs.io/']", text: 'API Docs'
  end
end
