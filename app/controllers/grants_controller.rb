class GrantsController < ApplicationController

  def index
    render json: Grant.includes(:beneficiaries).order(created_at: :desc).all
  end

  def create
    grant = Grant.create( grant_identifier: params[:grant_identifier],
                          funder_identifier: params[:funder_identifier],
                          recipient_identifier: params[:recipient_identifier])
    render json: grant
  end

  private

  def grant_params
    params.require(:grant).permit(:grant_identifier, :funder_identifier, :recipient_identifier)
  end

end
