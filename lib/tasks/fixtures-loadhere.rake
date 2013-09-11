desc "Load the fixtures into the current environment (probably dev)"
namespace :db do
  namespace :fixtures do
    task :load => [:environment, :load_config] do
      return unless Rails.env.development?
      TestEnvironment.reload_fixtures!
    end
  end
end
