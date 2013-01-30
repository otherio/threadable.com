Rake::Task['assets:precompile'].actions.unshift(proc{
  require 'widgets'
  Widgets.generate_sass!
})
