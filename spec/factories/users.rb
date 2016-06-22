FactoryGirl.define do
  factory :user do
    transient  { n { rand(9999) } }
    first_name 'Forename'
    last_name  'Surname'
    email      { "user_#{n}@email.com" }
    password   'password'

    factory :admin_user, class: User do
      role     'admin'
    end
  end
end
