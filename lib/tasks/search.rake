namespace :search do

  desc "reindex our Algolia indexs"
  task :reindex => :environment do
    User.reindex!
    Message.reindex!
  end

end
