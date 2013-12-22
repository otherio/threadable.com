factory :email_address do

  ignore do
    confirmed false
  end

  sequence(:address) {|i| "factoried-#{i}@example.com"}
  confirmed_at { confirmed ? Time.now : nil }
end
