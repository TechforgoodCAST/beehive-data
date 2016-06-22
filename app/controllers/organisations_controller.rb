class OrganisationsController < ApplicationController

  before_action :authenticate_user!
  before_action :load_organisation, only: [:edit, :update]

  def index
    if current_user.admin?
      @organisations = Organisation.approved.newest
    else
      redirect_to review_organisations_path
    end
  end

  def edit
    session[:return_to] ||= request.referer
    if @organisation.scrape.keys.count > 0 && !@organisation.approved?
      @organisation.attributes = @organisation.scrape['data'].except('regions', 'score')
    end
  end

  def update
    if @organisation.update(organisation_params)
      @organisation.next_step! unless @organisation.approved?
      @organisation.user_ids = User.ids(@organisation, current_user)
      redirect_to session.delete(:return_to) || review_organisations_path
    else
      render :edit
    end
  end

  def review
    @organisations = Organisation.newest
  end

  def scrape
    Organisation.import.order(updated_at: :desc).limit(10).each do |org|
      if org.scrape_org
        org.update_attribute(:scrape, org.scrape_org)
        org.update_attribute(:scraped_at, Time.now)
        if org.scrape['data']['score'] > 4
          org.update_attributes(org.use_scrape_data)
          org.update_attribute(:state, 'approved')
          org.user_ids = User.ids(org, current_user)
        else
          org.update_attribute(:state, 'review')
        end
      else
        org.update_attribute(:state, 'review')
      end
    end
    redirect_to review_organisations_path
  end

  private

    def organisation_params
      params.require(:organisation).permit(:organisation_identifier, :name,
        :charity_number, :company_number, :organisation_number,
        :organisation_number, :country_id, :org_type, :multi_national,
        :street_address, :city, :region, :postal_code, :website)
    end

    def load_organisation
      @organisation = Organisation.find_by(slug: params[:id])
    end

end
