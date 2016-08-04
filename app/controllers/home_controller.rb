class HomeController < ApplicationController

  def examples
    @data = HTTParty.get("http://#{request.host_with_port}/v1/demo/grants/2015")
  end

end
