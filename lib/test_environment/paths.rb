module TestEnvironment::Paths

  def path_to name
    case name
    when 'the home page'
      root_path
    else
      raise "\n\nCan't find mapping from \"#{name}\" to a path.\nNow, go and add a mapping in #{__FILE__}\n\n"
    end
  end

end
