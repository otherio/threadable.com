namespace :db do

  desc "populate the development db with useful things"
  task :populate => :environment do
    Db::Populate.call
  end

  task :reset do
    Rake::Task['db:fixtures:build'].invoke
    system('bundle exec rake db:test:prepare')
  end

  desc "Load the fixtures into the current environment (probably dev)"
  namespace :fixtures do
    task :build => :environment do
      return unless Rails.env.development? || Rails.env.test?
      Fixtures.build!
    end
  end

  namespace :backup do
    backup = -> environment do
      Bundler.with_clean_env do
        system("heroku pg:backups capture --expire --app threadable-#{environment}")
      end
    end
    desc "tells heroku to backup staging database"
    task :staging do
      backup.call :staging
    end
    desc "tells heroku to backup production database"
    task :production do
      backup.call :production
    end
  end

  namespace :download do
    download = -> environment do
      Bundler.with_clean_env do
        backup_path = Rails.root.join("tmp/#{environment}.dump")
        backup_url = `heroku pg:backups public-url --app threadable-#{environment}`.chomp
        puts "downloading #{backup_url.inspect}"
        system("curl -o #{backup_path.to_s.inspect} #{backup_url.inspect}")
      end
    end
    desc "downloads staging database into tmp/staging.dump"
    task :staging do
      download.call :staging
    end
    desc "downloads production database into tmp/production.dump"
    task :production do
      download.call :production
    end
  end

  namespace :store do
    store = -> environment, args do
      Bundler.with_clean_env do
        unless args[:path] && args[:recipient]
          raise ArgumentError, "You must specify a path and recipient"
        end

        Rake::Task["db:download:#{environment}"].invoke

        time_string = Time.now.getutc.to_formatted_s(:number)
        output_path = "#{args[:path]}/#{environment}-#{time_string}.dump.gpg"
        backup_path = Rails.root.join("tmp/#{environment}.dump")

        `gpg --encrypt --recipient #{args[:recipient]} --output #{output_path} #{backup_path}`
        `rm -f #{backup_path}`
        puts "Backup archived at #{output_path}"
      end
    end
    desc "Stores an encrypted backup of the staging database"
    task :staging, :path, :recipient do |t, args|
      store.call :staging, args
    end
    desc "Stores an encrypted backup of the production database"
    task :production, :path, :recipient do |t, args|
      store.call :production, args
    end
  end

  namespace :import do
    import = -> environment do
      Bundler.with_clean_env do
        backup_path = Rails.root.join("tmp/#{environment}.dump")
        Rake::Task["db:download:#{environment}"].invoke unless backup_path.exist?
        abort "#{backup_path} does not exist" unless backup_path.exist?
        puts "importing #{backup_path}"
        system("pg_restore --verbose --clean --no-acl --no-owner -h localhost -U #{`whoami`.chomp} -d threadable_development #{backup_path.to_s.inspect}")
      end
    end
    desc "imports tmp/staging.dump"
    task :staging => %w{db:drop:all db:create:all} do
      import.call :staging
    end
    desc "imports tmp/production.dump"
    task :production => %w{db:drop:all db:create:all} do
      import.call :production
    end
  end

end
