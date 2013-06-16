require 'active_record/fixtures'

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

  class << self

    def configure_fixture_builder!
      return if @fixture_builder_configured
      require 'fixture_builder'
      require 'active_record/fixtures'
      require 'database_cleaner'
      require 'fixture_builder/configuration'

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

    def fixtures
      @fixtures ||= begin
        # configure_fixture_builder!
        Dir[FIXTURES].each_with_object(Hash.new) do |fixture, hash|
          table_name = File.basename(fixture, '.yml')
          hash[table_name] = YAML.load(File.read(fixture))
        end
      end
    end

    def load!
      fixtures.each do |table_name, records|
        truncate table_name
        Array(records).each do |fixture_name, record|
          insert(table_name, fixture_name, record)
        end
        reset_pk_sequence table_name
      end
    end

    private

    def truncate table_name
      connection.delete "DELETE FROM #{connection.quote_table_name(table_name)}"
    end

    def reset_pk_sequence table_name
      connection.reset_pk_sequence! table_name
    end

    def insert table_name, fixture_name, record
      columns = Hash[connection.columns(table_name).map { |c| [c.name, c] }]
      table_name = connection.quote_table_name(table_name)

      column_names = []
      values = []

      record.each do |column_name, value|
        column_names << connection.quote_column_name(column_name)
        values << connection.quote(value, columns[column_name])
      end

      connection.insert "INSERT INTO #{table_name} (#{column_names.join(', ')}) VALUES (#{values.join(', ')})", "Inserting Fixture #{fixture_name.inspect}"
    end

    def connection
      ::ActiveRecord::Base.connection
    end

  end

end
