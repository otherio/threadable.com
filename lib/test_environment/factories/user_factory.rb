FactoryGirl.define do
  factory :user, :class => "Covered::User" do

    ignore do
      web_enabled false
    end

    sequence(:name)       {|i| "user #{i}"}
    email                 {|user| "#{user.name.gsub(/\s+/,'_')}@example.com"}
    password              { 'password' if web_enabled }
    password_confirmation { 'password' if web_enabled }

  end
end
