#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
Threadable::Application.load_tasks


task :reset do
  Threadable.redis.flushdb
  Rake::Task['db:reset'].invoke
end
