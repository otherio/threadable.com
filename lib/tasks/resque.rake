task "resque:setup" => :environment do
  ENV['QUEUE'] ||= '*'
end
