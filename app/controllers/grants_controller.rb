class GrantsController < ApplicationController

  before_action :authenticate_user!
  before_action :load_grant, only: [:edit, :update]

  def index
    if current_user.admin?
      @grants = Grant.approved.newest
    else
      redirect_to review_grants_path
    end
  end

  def edit
    session[:return_to] ||= request.referer
    @grant.scrape_grant unless @grant.approved?
  end

  def update
    params[:grant][:district_ids] = @grant.check_regions(params[:grant][:district_ids])
    if @grant.update(grant_params)
      @grant.next_step! unless @grant.approved?
      @grant.user_ids = User.ids(@grant, current_user)
      redirect_to session.delete(:return_to) || review_grants_path
    else
      render :edit
    end
  end

  def review
    @grants = Grant.newest
  end

  def scrape
    Grant.with_approved_recipients.take(params[:review].to_i).each do |grant|
      grant.update_attribute(:state, 'review')
      grant.next_step! if grant.scrape_grant && grant.save
    end
    redirect_to review_grants_path
  end

  private

    def grant_params
      params.require(:grant).permit(:award_year, :funder_id, :recipient_id, :grant_identifier,
        :title, :description, :currency, :funding_programme, :gender, :amount_awarded,
        :amount_applied_for, :amount_disbursed, :award_date, :planned_start_date,
        :planned_end_date, :open_call, :affect_people, :affect_other, :operating_for,
        :income, :spending, :employees, :volunteers, :geographic_scale, :type_of_funding,
        country_ids: [], district_ids: [], age_group_ids: [], beneficiary_ids: [])
    end

    def load_grant
      @grant = Grant.find(params[:id])
    end

end
