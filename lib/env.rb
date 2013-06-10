File.read(File.expand_path('../../.env', __FILE__)).split("\n").each do |line|
  name, value = line.split('=')
  ENV[name] = value
end
