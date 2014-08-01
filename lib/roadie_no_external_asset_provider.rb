class RoadieNoExternalAssetProvider < Roadie::FilesystemProvider
  def find_stylesheet(name)
    if name == 'email' || name == 'message_summary'
      super
    else
      nil
    end
  end
end
