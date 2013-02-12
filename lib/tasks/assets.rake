Rake::Task['assets:precompile'].clear

namespace :assets do

  desc "Generate widgets.sass & compile all the assets named in config.assets.precompile"
  task :precompile do
    Rails::Widgets.generate_sass!
    invoke_or_reboot_rake_task "assets:precompile:all"
  end

end
