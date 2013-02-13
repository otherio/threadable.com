desc "Load the fixtures into the current environment (probably dev)"
namespace :db do
  namespace :fixtures do
    task :loadhere => :environment do
      TestEnvironment::Fixtures.build!
    end
  end
end
