class FundsController < ApplicationController

  before_action :authenticate_user!

  def status
    @funds = Grant.order(:fund_slug).pluck(:fund_slug).uniq
  end
end
