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
    backup = -> environment do
      Bundler.with_clean_env do
        system("heroku pgbackups:capture --app covered-#{environment}")
      end
    end
    task :staging do
      backup.call :staging
    end
    task :production do
      backup.call :production
    end
  end

  namespace :download do
    download = -> environment do
      Bundler.with_clean_env do
        backup_path = Rails.root.join("tmp/#{environment}.dump")
        backup_url = `heroku pgbackups:url --app covered-#{environment}`.chomp
        puts "downloading #{backup_url.inspect}"
        system("curl -o #{backup_path.to_s.inspect} #{backup_url.inspect}")
      end
    end
    task :staging do
      download.call :staging
    end
    task :production do
      download.call :production
    end
  end

  namespace :import do
    import = -> environment do
      Bundler.with_clean_env do
        backup_path = Rails.root.join("tmp/#{environment}.dump")
        Rake::Task["db:download:#{environment}"].invoke unless backup_path.exist?
        abort "#{backup_path} does not exist" unless backup_path.exist?
        puts "importing #{backup_path}"
        system("pg_restore --verbose --clean --no-acl --no-owner -h localhost -U #{`whoami`.chomp} -d covered_development #{backup_path.to_s.inspect}")
      end
    end
    task :staging => %w{db:drop:all db:create:all} do
      import.call :staging
    end
    task :production => %w{db:drop:all db:create:all} do
      import.call :production
    end
  end

end
