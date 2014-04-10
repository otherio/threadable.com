factory :user do

  ignore do
    web_enabled false
    email_address nil
  end

  sequence(:name)       {|i| "user #{i}"}
  password              { web_enabled ? 'password' : '' }
  password_confirmation { web_enabled ? 'password' : '' }

  after :build do |user, evaluator|
    user.email_addresses << build(:email_address,
      address: evaluator.email_address || "#{user.name.gsub(/\s+/,'.')}@example.com",
      primary: true,
      confirmed: true,
    )
  end
end
