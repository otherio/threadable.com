require 'childprocess'

class Multify::Servers::RailsApp

  attr_reader :port

  def path
    @path ||= Multify.root.join(self.class.name.split('::').last.downcase)
  end

  RAILS_ENV = ENV['RAILS_ENV'] || 'development' # TODO make an integration env

  def start!
    Bundler.with_clean_env do
      ENV['RAILS_ENV'] = RAILS_ENV
      child_process.start
      puts "Started #{self} in #{path} at #{child_process.pid}"
    end
  end

  def child_process
    @child_process ||= ChildProcess.build(command)
  end

  def command
    @port = find_available_port!
    <<-SH.gsub(/\n/,'')
      cd #{path} &&
      (bundle check || bundle install) &&
      RAILS_ENV=development bundle exec rails server -p #{@port}
    SH
  end

  def find_available_port!
    TCPServer.new('127.0.0.1', 0).addr[1]
  end

end
