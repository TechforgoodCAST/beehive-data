class AddLicenseToGrants < ActiveRecord::Migration
  def change
    add_column :grants, :license, :string
    add_column :grants, :source, :string
    remove_column :organisations, :license, :string
  end
end
