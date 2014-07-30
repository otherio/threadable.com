class RoadieNoExternalAssetProvider < Roadie::FilesystemProvider
  def find_stylesheet(name)
    binding.pry
    if name == 'email' || name == 'message_summary'
      super
    else
      nil
    end
  end
end
