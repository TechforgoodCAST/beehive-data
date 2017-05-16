class HomeController < ApplicationController

  def examples
    @data = HTTParty.get(v1_examples_by_year_url('2015'), timeout: 15)
  end

end
