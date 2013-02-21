module TestEnvironment::Fixtures

  FIXTURE_PATH = Rails.root.join("lib/test_environment/fixtures")
  FIXTURES     = FIXTURE_PATH.join('*.yml')
  BUILDERS     = FIXTURE_PATH.join('builders/*.rb')
  FACTORIES    = Rails.root.join('lib/test_environment/factories/*.rb')
  MODELS       = Rails.root.join('app/models/*.rb')
  SCHEMA       = Rails.root.join("db/schema.rb")

  def fixture_path
    FIXTURE_PATH.to_s
  end

  def self.configure_fixture_builder!
    return if @fixture_builder_configured
    require 'fixture_builder'
    require 'active_record/fixtures'
    require 'database_cleaner'
    require 'fixture_builder/configuration'

    ActiveSupport::TestCase.fixture_path = FIXTURE_PATH.to_s

    ::FixtureBuilder::Configuration.class_eval do
      def fixtures_dir(path = '')
        FIXTURE_PATH.join(path).to_s
      end
    end

    ::FixtureBuilder.configure do |fbuilder|
      # rebuild fixtures automatically when these files change:
      fbuilder.files_to_check += \
        Dir[BUILDERS] + Dir[FACTORIES] + Dir[MODELS] + [SCHEMA, __FILE__]

      # now declare objects
      fbuilder.factory do
        load Rails.root.join('db/seeds.rb')
        Dir[BUILDERS].each{|fixture| load fixture }
      end
    end
    @fixture_builder_configured = true
  end

  def self.load!
    configure_fixture_builder!
    ::ActiveRecord::Fixtures.reset_cache
    fixtures_folder = FIXTURE_PATH.to_s
    table_names = Dir[FIXTURES].map{ |f| File.basename(f, '.yml') }
    ::DatabaseCleaner.clean_with :truncation
    ::ActiveRecord::Fixtures.create_fixtures(fixtures_folder, table_names)
    nil
  end

end
