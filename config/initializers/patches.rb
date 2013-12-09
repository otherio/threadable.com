Dir[Rails.root.join('lib/patches/*.rb')].each{|p| require p}
