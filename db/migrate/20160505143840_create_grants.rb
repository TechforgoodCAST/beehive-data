class CreateGrants < ActiveRecord::Migration
  def change
    create_table :grants do |t|
      t.references :funder, required: true, index: true
      t.references :recipient, required: true, index: true
      t.string :grant_identifier, required: true, index: true, uniqe: true
      t.string :title, :description, :currency, :funding_programme, required: true
      t.string :gender
      t.string :state, default: 'import', required: true
      t.decimal :amount_awarded, required: true
      t.decimal :amount_applied_for, :amount_disbursed
      t.date :award_date, required: true
      t.date :planned_start_date, :planned_end_date
      t.boolean :open_call, :affect_people, :affect_other
      t.integer :year, required: true
      t.integer :operating_for, :income, :spending, :employees, :volunteers, :geographic_scale, :type_of_funding
      t.timestamps null: false
    end

    create_table :beneficiaries do |t|
      t.string :label, :sort, required: true, index: true, uniqe: true
      t.string :group, required: true
      t.timestamps null: false
    end

    create_table :stakeholders do |t|
      t.references :beneficiary, required: true, index: true
      t.references :grant, required: true, index: true
      t.timestamps null: false
    end

    create_table :age_groups do |t|
      t.string :label, required: true, index: true, uniqe: true
      t.integer :age_from, :age_to, required: true
      t.timestamps null: false
    end

    create_table :ages do |t|
      t.references :age_group
      t.references :grant
    end

    create_table :countries do |t|
      t.string :name, :alpha2, required: true, index: true, uniqe: true
      t.string :currency_code, index: true
      t.timestamps null: false
    end

    create_table :locations do |t|
      t.references :country
      t.references :grant
    end

    create_table :districts do |t|
      t.references :country, required: true, index: true
      t.string :name, required: true, index: true, uniqe: true
      t.string :subdivision, :region, :sub_country
      t.timestamps null: false
    end

    create_table :regions do |t|
      t.references :district
      t.references :grant
    end

    create_table :organisations do |t|
      t.references :country, required: true, index: true
      t.string :organisation_identifier, :slug, required: true, index: true, uniqe: true
      t.string :charity_number, :company_number, :organisation_number, index: true, uniqe: true
      t.string :name, required: true
      t.string :state, default: 'import', required: true
      t.string :street_address, :city, :region, :postal_code, :website, :company_type
      t.date :incorporated_date
      t.integer :org_type, required: true
      t.boolean :publisher, default: false
      t.boolean :multi_national, :registered
      t.float :latitude, :longitude
      t.json :scrape, default: {}, null: false
      t.datetime :scraped_at
      t.timestamps null: false
    end
  end
end
