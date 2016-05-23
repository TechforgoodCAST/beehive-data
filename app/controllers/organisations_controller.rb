class OrganisationsController < ApplicationController

  before_action :authenticate_user!, :load_organisation

  def review
    @organisations = Organisation.order(updated_at: :desc)
  end

  def scrape
    Organisation.import.order(updated_at: :desc).limit(10).each do |org|
      if org.public_find
        org.update_attribute(:scrape, org.public_find)
        org.update_attribute(:scraped_at, Time.now)
        if org.scrape['data']['score'] > 4
          org.update_attributes(org.use_scrape_data)
          org.update_attribute(:state, 'approved')
        else
          org.update_attribute(:state, 'review')
        end
      else
        org.update_attribute(:state, 'review')
      end
    end
    redirect_to review_organisations_path
  end

  def edit
    if @organisation.scrape.keys.count > 0
      @organisation.attributes = @organisation.scrape['data'].except('regions', 'score')
    end
  end

  def update
    if @organisation.update(organisation_params)
      @organisation.next_step! unless @organisation.approved?
      redirect_to review_organisations_path
    else
      render :edit
    end
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
