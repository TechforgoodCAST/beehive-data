class RecipientsController < ApplicationController

  def index
    render json: Organisation.recipients
  end

end
