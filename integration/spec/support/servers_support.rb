module ServersSupport

  def start_servers!
    process = ChildProcess.build("ruby", "-e", "sleep")
    process.io.inherit!
    process.start
  end

end
