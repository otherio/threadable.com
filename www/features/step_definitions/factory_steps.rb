Given /^the following users:$/ do |table|
  table.hashes.each do |user|
    Multify::User.create(user)
  end
end

Given /^the following projects:$/ do |table|
  table.hashes.each do |project|
    Multify::Project.create(project)
  end
end

Given /^the following tasks:$/ do |table|
  table.hashes.each do |task|
    project = Multify::Project.find(name: task.delete('project')).first
    project.tasks.create(task)
  end
end
