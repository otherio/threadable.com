require 'guard'
require 'guard/guard'

module Guard
  class Schema < Guard

    def initialize(watchers=[], options={})
      super
      options[:notify] = true if options[:notify].nil?
    end

    def start
      true
    end

    def stop
      true
    end

    def reload
      true
    end

    def run_all
      true
    end

    def run_on_change(paths)
      run_db_test_prepare
    end

    # Called on file(s) deletions
    def run_on_deletion(paths)
      true
    end

    private

    def notify?
      !!options[:notify]
    end

    def run_db_test_prepare
      UI.info "Guard::Schema is running rake db:test:prepare"
      started_at = Time.now
      result, image = if system("bundle exec rake db:test:prepare")
        ["Database schema prepared successfully", :success]
      else
        ["Error while preparing database schema", :failed]
      end
      UI.info result
      UI.info "rake db:test:prepare ended #{Time.now - started_at} seconds"
      ::Guard::Notifier.notify(result, :title => 'rake db:test:prepare', :image => image) if notify?
      result
    end

  end

end
