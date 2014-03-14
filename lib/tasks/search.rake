namespace :search do

  desc "reindex our Algolia indexs"
  task :reindex => :environment do
    Message.reindex!
  end

end
