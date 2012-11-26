require 'childprocess'
require 'socket'

class Multify::Servers::RailsApp

  def app_name
    self.class.name.split('::').last.downcase
  end

  def app_path
    @app_path ||= Multify.root.join(app_name)
  end

  def log_path
    @log_path ||= Multify.root.join("integration/log/#{app_name}.log")
  end

  RAILS_ENV = ENV['RAILS_ENV'] || 'development' # TODO make an integration env

  def start!
    Bundler.with_clean_env do
      ENV['RAILS_ENV'] = RAILS_ENV

      begin
        current_dir = Dir.pwd
        Dir.chdir(app_path)

        `bundle check || bundle install`
        child_process.start
        at_exit{ child_process.wait }

        puts "Started #{self} in #{app_path} at #{child_process.pid}"
      ensure
        Dir.chdir(current_dir)
      end
    end
  end

  def child_process
    @child_process ||= begin
      child_process = ChildProcess.build(%W{bundle exec rails server -p #{port}})
      child_process.io.stdout = File.open(log_path, 'w')
      child_process
    end
  end

  def port
    @port ||= find_available_port!
  end

  # def command
  #   @port = find_available_port!
  #   <<-SH.gsub(/\n/,'')
  #     cd #{app_path} &&
  #     (bundle check || bundle install) &&
  #     RAILS_ENV=development bundle exec rails server -p #{@port}
  #   SH
  # end

  def find_available_port!
    TCPServer.new('127.0.0.1', 0).addr[1]
  end

end
