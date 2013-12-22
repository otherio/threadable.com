factory :user do

  ignore do
    web_enabled false
    email_address nil
  end

  sequence(:name)       {|i| "user #{i}"}
  password              { 'password' if web_enabled }
  password_confirmation { 'password' if web_enabled }

  after :build do |user, evaluator|
    user.email_addresses << build(:email_address,
      address: evaluator.email_address || "#{user.name.gsub(/\s+/,'.')}@example.com",
      primary: true,
      confirmed: true,
    )
  end
end
