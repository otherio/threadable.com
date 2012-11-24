
# This will guess the User class
FactoryGirl.define do
  sequence :email do |n|
    "test#{n}@example.com"
  end

  factory :user do
    name "Some Guy"
    email
    password 'password'
    password_confirmation 'password'
  end
end
