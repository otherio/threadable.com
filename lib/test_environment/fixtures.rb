module TestEnvironment::Fixtures

  FIXTURES = Rails.root.join("lib/test_environment/fixtures")
  BUILDERS = FIXTURES.join('builders/*.rb')

  def self.configure_fixture_builder!
    return if @fixture_builder_configured
    require 'fixture_builder'
    require 'active_record/fixtures'
    require 'database_cleaner'
    require 'fixture_builder/configuration'

    ::FixtureBuilder::Configuration.class_eval do
      def fixtures_dir(path = '')
        FIXTURES.join(path).to_s
      end
    end

    ::FixtureBuilder.configure do |fbuilder|
      # rebuild fixtures automatically when these files change:
      fbuilder.files_to_check += \
        Dir[Rails.root.join('lib/test_environment/factories/*.rb')] +
        Dir[BUILDERS] + [__FILE__]

      # now declare objects
      fbuilder.factory do

        load Rails.root.join('db/seeds.rb')
        Dir[BUILDERS].each do |fixture|
          load fixture
        end

      end
    end
    @fixture_builder_configured = true
  end

  def self.load!
    configure_fixture_builder!
    ::ActiveRecord::Fixtures.reset_cache
    fixtures_folder = ::Rails.root.join('lib/test_environment/fixtures')
    fixtures = Dir[File.join(fixtures_folder, '*.yml')].map { |f| File.basename(f, '.yml') }
    ::DatabaseCleaner.clean_with :truncation
    ::ActiveRecord::Fixtures.create_fixtures(fixtures_folder, fixtures)
    nil
  end

end
