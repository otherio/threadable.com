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

end
