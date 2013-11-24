factory :user do

  ignore do
    web_enabled false
  end

  sequence(:name)       {|i| "user #{i}"}
  email_address         {|user| "#{user.name.gsub(/\s+/,'_')}@user-factory.org"}
  password              { 'password' if web_enabled }
  password_confirmation { 'password' if web_enabled }

end
