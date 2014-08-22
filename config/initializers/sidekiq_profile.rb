#http://www.happybootstrapper.com/2014/profile-leaky-sidekiq-job-heroku/

if ENV["SIDEKIQ_PROFILE"]
  require "objspace"
  ObjectSpace.trace_object_allocations_start
  Sidekiq.logger.info "allocations tracing enabled"

  module Sidekiq
    module Middleware
      module Server
        class Profiler
          # Number of jobs to process before reporting
          JOBS = 30

          class << self
            mattr_accessor :counter
            self.counter = 0

            def synchronize(&block)
              @lock ||= Mutex.new
              @lock.synchronize(&block)
            end
          end

          def call(worker_instance, item, queue)
            begin
              yield
            ensure
              self.class.synchronize do
                self.class.counter += 1

                if self.class.counter % JOBS == 0
                  Sidekiq.logger.info "reporting allocations after #{self.class.counter} jobs"
                  GC.start
                  ObjectSpace.dump_all(output: File.open("heap.json", "w"))
                  Sidekiq.logger.info "heap saved to heap.json"
                end
              end
            end
          end
        end
      end
    end
  end

  Sidekiq.configure_server do |config|
    config.server_middleware do |chain|
      chain.add Sidekiq::Middleware::Server::Profiler
    end
  end
end
