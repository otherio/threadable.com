desc "Load the fixtures into the current environment (probably dev)"
namespace :db do
  namespace :fixtures do
    task :load => [:environment, :load_config] do
      TestEnvironment::Fixtures.configure_fixture_builder!
      TestEnvironment::Fixtures.load!
    end
  end
end
