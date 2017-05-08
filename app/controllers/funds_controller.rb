class FundsController < ApplicationController

  before_action :authenticate_user!

  def status
    @funds = Grant.pluck(:fund_slug).uniq
  end
end
