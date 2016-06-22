require 'rails_helper'

describe User do
  before(:each) do
    basic_setup
    create_and_auth_moderator
  end

  it 'is moderator by default' do
    expect(User.new.role).to eq 'moderator'
  end

  it 'has many approved organisation' do
    @recipient.update_column(:state, 'approved')
    @funder.update_column(:state, 'approved')
    @moderator.organisation_ids = [@recipient.id, @funder.id]
    expect(@moderator.organisations.approved.count).to eq 2
  end

  it 'has many approved grants' do
    grant2 = create(:grant, funder: @funder, recipient: @recipient)
    grant2.update_column(:state, 'approved')
    @grant.update_column(:state, 'approved')
    @moderator.grant_ids = [@grant.id, grant2.id]
    expect(@moderator.grants.approved.count).to eq 2
  end
end
