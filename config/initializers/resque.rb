Resque.after_fork = Proc.new { ActiveRecord::Base.connection.reconnect! }
Resque.queues # this fixed a weird edgecase
