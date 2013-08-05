FactoryGirl.define do
  factory :user do

    ignore do
      web_enabled false
    end

    sequence(:name)       {|i| "user #{i}"}
    email                 {|user| "#{user.name.gsub(/\s+/,'_')}@example.com"}
    password              { 'password' if web_enabled }
    password_confirmation { 'password' if web_enabled }
    confirmed_at          { Time.now }

  end
end
