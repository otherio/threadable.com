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
      command = 'rake -t -v db:schema:load db:test:prepare'
      UI.info "Guard::Schema is running #{command}"
      started_at = Time.now
      result, image = if system("bundle exec #{command}")
        ["Database schema prepared successfully", :success]
      else
        ["Error while preparing database schema", :failed]
      end
      UI.info result
      UI.info "#{command} ended #{Time.now - started_at} seconds"
      ::Guard::Notifier.notify(result, :title => command, :image => image) if notify?
      result
    end

  end

end
