class GrantsController < ApplicationController

  before_action :authenticate_user!
  before_action :load_grant, only: [:edit, :update]

  def index
    @grants = Grant.approved
  end

  # TODO: refactor
  def create
    grant = Grant.create( grant_identifier: params[:grant_identifier],
                          funder_id: params[:funder_id],
                          recipient_id: params[:recipient_id])
    render json: grant
  end

  def edit
    @grant.scrape_grant unless @grant.approved?
  end

  def update
    if @grant.update(grant_params)
      @grant.next_step! unless @grant.approved?
      redirect_to review_grants_path
    else
      render :edit
    end
  end

  def review
    @grants = Grant.order(updated_at: :desc)
  end

  def scrape
    Grant.with_approved_recipients.take(10).each do |grant|
      grant.update_attribute(:state, 'review')
      grant.next_step! if grant.scrape_grant && grant.save
    end
    redirect_to review_grants_path
  end

  private

    def grant_params
      params.require(:grant).permit(:year, :funder_id, :recipient_id, :grant_identifier,
        :title, :description, :currency, :funding_programme, :gender, :amount_awarded,
        :amount_applied_for, :amount_disbursed, :award_date, :planned_start_date,
        :planned_end_date, :open_call, :affect_people, :affect_other, :operating_for,
        :income, :spending, :employees, :volunteers, :geographic_scale,
        country_ids: [], district_ids: [], age_group_ids: [], beneficiary_ids: [])
    end

    def load_grant
      @grant = Grant.find(params[:id])
    end

end
