Resque.after_fork = Proc.new { ActiveRecord::Base.connection.reconnect! }
