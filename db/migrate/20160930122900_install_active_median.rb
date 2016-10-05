class InstallActiveMedian < ActiveRecord::Migration
  def up
    ActiveMedian.create_function
  end
end
