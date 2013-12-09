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

  namespace :backup do
    task :staging do
      Bundler.with_clean_env do
        system('heroku pgbackups:capture --app covered-staging')
      end
    end
    task :production do
      Bundler.with_clean_env do
        system('heroku pgbackups:capture --app covered-production')
      end
    end
  end

  namespace :download do
    task :staging do
      Bundler.with_clean_env do
        backup_path = Rails.root.join('tmp/staging.dump')
        backup_url = `heroku pgbackups:url --app covered-staging`.chomp
        puts "downloading #{backup_url.inspect}"
        system("curl -o #{backup_path.to_s.inspect} #{backup_url.inspect}")
      end
    end
  end

  namespace :import do
    task :staging => %w{db:drop:all db:create:all} do
      Bundler.with_clean_env do
        backup_path = Rails.root.join('tmp/staging.dump')
        Rake::Task['db:download:staging'].invoke unless backup_path.exist?
        abort "#{backup_path} does not exist" unless backup_path.exist?
        puts "importing #{backup_path}"
        system("pg_restore --verbose --clean --no-acl --no-owner -h localhost -U #{`whoami`.chomp} -d covered_development #{backup_path.to_s.inspect}")
      end
    end
  end

end
