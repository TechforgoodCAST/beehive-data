class DocsController < ApplicationController
  before_action :authenticate_user!

  def moderators; end
end
