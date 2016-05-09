class CreateGrants < ActiveRecord::Migration
  def change
    create_table :grants do |t|
      t.references :funder, required: true, index: true
      t.references :recipient, required: true, index: true
      t.string :grant_identifier, required: true, index: true, uniqe: true
      t.string :title, :description, :currency, :funding_programme, required: true
      t.string :gender
      t.decimal :amount_awarded, required: true
      t.decimal :amount_applied_for, :amount_disbursed
      t.date :award_date, required: true
      t.date :planned_start_date, :planned_end_date
      t.boolean :open_call, :affect_people, :affect_other
      t.timestamps null: false
    end

    create_table :beneficiaries do |t|
      t.string :label, :sort, required: true, index: true, uniqe: true
      t.timestamps null: false
    end

    create_table :beneficiaries_grants do |t|
      t.references :beneficiary, required: true, index: true
      t.references :grant, required: true, index: true
      t.timestamps null: false
    end

    create_table :age_groups do |t|
      t.string :label, :age_from, :age_to, required: true, index: true, uniqe: true
      t.timestamps null: false
    end

    create_table :age_groups_grants do |t|
      t.references :age_group
      t.references :grant
    end

    create_table :countries do |t|
      t.string :name, :alpha2, required: true, index: true, uniqe: true
      t.timestamps null: false
    end

    create_table :countries_grants do |t|
      t.references :country
      t.references :grant
    end

    create_table :districts do |t|
      t.references :country, required: true, index: true
      t.string :name, required: true, index: true, uniqe: true
      t.string :subdivision, :region, :sub_country
      t.timestamps null: false
    end

    create_table :districts_grants do |t|
      t.references :district
      t.references :grant
    end

    create_table :organisations do |t|
      t.references :country, required: true, index: true
      t.string :organisation_identifier, required: true, index: true, uniqe: true
      t.string :slug, required: true, index: true, uniqe: true
      t.string :name, :charity_number, :company_number, required: true
      t.string :street_address, :city, :region, :postal_code, :website, :registered_name, :company_type
      t.integer :org_type, :operating_for, :income, :spending, :employees, :volunteers, required: true
      t.boolean :publisher, :multi_national
      t.float :latitude, :longitude
      t.timestamps null: false
    end
  end
end
