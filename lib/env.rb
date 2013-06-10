path = File.expand_path('../../.env', __FILE__)
if File.exist?(path)
  File.read(path).split("\n").each do |line|
    name, value = line.split('=')
    ENV[name] = value
  end
end
