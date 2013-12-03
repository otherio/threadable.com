namespace :db do

  desc "populate the development db with useful things"
  task :populate => :environment do
    Db::Populate.call
  end

  task :reset do
    Rake::Task['db:fixtures:rebuild'].invoke
  end

  desc "Load the fixtures into the current environment (probably dev)"
  namespace :fixtures do
    task :rebuild => :environment do
      return unless Rails.env.development? || Rails.env.test?
      require 'activerecord/fixture_builder'
      load Rails.root.join('config/initializers/activerecord-fixture_builder.rb').to_s
      ActiveRecord::FixtureBuilder.fixtures.map(&:path).each(&:delete)
      ActiveRecord::FixtureBuilder.build_fixtures!
      ActiveRecord::FixtureBuilder.write_fixtures!
    end
  end

  namespace :import do
    task :staging do
      Bundler.with_clean_env do
        backup_path = Rails.root.join('tmp/staging.dump').to_s
        backup_url = `heroku pgbackups:url --app covered-staging`.chomp
        puts "downloading #{backup_url.inspect}"
        puts `curl -o #{backup_path.inspect} #{backup_url.inspect}`
        puts "importing #{backup_path}"
        puts `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U #{`whoami`.chomp} -d covered_development #{backup_path.inspect}`
      end
    end
  end

end
