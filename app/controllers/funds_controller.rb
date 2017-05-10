class FundsController < ApplicationController

  before_action :authenticate_user!

  def status
    @funds = Grant.order(:fund_slug).pluck(:fund_slug).uniq
    @all_grants_count = Grant.group(:fund_slug).count
    @state_count = Grant.group(:fund_slug, :state).count
  end
end
