class RoadieNoExternalAssetProvider < Roadie::AssetPipelineProvider
  def find(name)
    if name == 'email' || name == 'message_summary'
      super
    else
      ''
    end
  end
end
