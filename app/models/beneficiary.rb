class Beneficiary < ActiveRecord::Base

  scope :people, -> { where(group: 'People') }
  scope :other,  -> { where(group: 'Other') }

  BENEFICIARIES = [
    {
      label: "The general public",
      group: "People",
      sort:  "public"
    },
    {
      label: "Affected or involved with crime",
      group: "People",
      sort:  "crime"
    },
    {
      label: "With family/relationship challenges",
      group: "People",
      sort:  "relationship"
    },
    {
      label: "With disabilities",
      group: "People",
      sort:  "disabilities"
    },
    {
      label: "With specific religious/spiritual beliefs",
      group: "People",
      sort:  "religious"
    },
    {
      label: "Affected by disasters",
      group: "People",
      sort:  "disasters"
    },
    {
      label: "In education",
      group: "People",
      sort:  "education"
    },
    {
      label: "Who are unemployed",
      group: "People",
      sort:  "unemployed"
    },
    {
      label: "From a specific ethnic background",
      group: "People",
      sort:  "ethnic"
    },
    {
      label: "With water/sanitation access challenges",
      group: "People",
      sort:  "water"
    },
    {
      label: "With food access challenges",
      group: "People",
      sort:  "food"
    },
    {
      label: "With housing/shelter challenges",
      group: "People",
      sort:  "housing"
    },
    {
      label: "Animals and wildlife",
      group: "Other",
      sort:  "animals"
    },
    {
      label: "Buildings and places",
      group: "Other",
      sort:  "buildings"
    },
    {
      label: "With mental diseases or disorders",
      group: "People",
      sort:  "mental"
    },
    {
      label: "With a specific sexual orientation",
      group: "People",
      sort:  "orientation"
    },
    {
      label: "Climate and the environment",
      group: "Other",
      sort:  "environment"
    },
    {
      label: "With physical diseases or disorders",
      group: "People",
      sort:  "physical"
    },
    {
      label: "Organisations",
      group: "Other",
      sort:  "organisations"
    },
    {
      label: "Facing income poverty",
      group: "People",
      sort:  "poverty"
    },
    {
      label: "Who are refugees and asylum seekers",
      group: "People",
      sort:  "refugees"
    },
    {
      label: "Involved with the armed or rescue services",
      group: "People",
      sort:  "services"
    },
    {
      label: "In, leaving, or providing care",
      group: "People",
      sort:  "care"
    },
    {
      label: "At risk of sexual exploitation, trafficking, forced labour, or servitude",
      group: "People",
      sort:  "exploitation"
    }
  ]

  has_many :stakeholders
  has_many :grants, through: :stakeholders

  validates :label, :sort, :group, presence: true
  validates :label, :sort, uniqueness: true

end
