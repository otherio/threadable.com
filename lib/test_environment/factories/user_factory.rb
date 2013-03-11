FactoryGirl.define do
  factory :user do
    sequence(:name)       {|i| "user #{i}"}
    email                 {|user| "#{user.name.gsub(/\s+/,'_')}@example.com"}
    password              'password'
    password_confirmation 'password'
  end
end
