require 'csv'

class AddAltnamesToCountries < ActiveRecord::Migration
  def up
    add_column :countries, :altnames, :json

    say_with_time "Update alternative country names" do
      CSV.foreach(Rails.root.join('lib', 'assets', 'csv', 'countries.csv'), headers: true) do |row|
        data = row.to_hash
        data["altnames"] = (data["altnames"] || "").split(",")
        c = Country.where(alpha2: data["alpha2"]).first_or_initialize
        c.update(data)
        c.save!
      end
    end
  end

  def down
    remove_column :countries, :altnames, :json
  end
end
