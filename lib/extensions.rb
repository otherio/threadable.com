Dir[__FILE__.sub(/\.rb\Z/,'')+'/*.rb'].each do |path|
  require path
end
