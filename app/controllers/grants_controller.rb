class GrantsController < ApplicationController

  before_action :authenticate_user!

  def index
    render json: Grant.includes(:beneficiaries).order(created_at: :desc).all
  end

  def create
    grant = Grant.create( grant_identifier: params[:grant_identifier],
                          funder_id: params[:funder_id],
                          recipient_id: params[:recipient_id])
    render json: grant
  end

  private

  def grant_params
    params.require(:grant).permit(:grant_identifier, :funder_id, :recipient_id)
  end

end
