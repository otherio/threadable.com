ActiveRecord::Base.configurations[Rails.env]["pool"] = Integer(ENV['DB_POOL']) if ENV['DB_POOL'].present?
ActiveRecord::Base.establish_connection
