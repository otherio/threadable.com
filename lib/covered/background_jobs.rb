class Covered::BackgroundJobs

  include Covered::Dependant

  def enqueue operation_name, options={}
    covered.operations.respond_to?(operation_name) or raise ArgumentError, "#{operation_name} is not an operation"
    Sidekiq::Client.push('class' => Worker, 'args' => [covered.env, operation_name, options])
  end

  class Worker
    include Sidekiq::Worker

    def perform env, operation_name, options
      Covered.new(env).operations.public_send(operation_name, options)
    end
  end

end
