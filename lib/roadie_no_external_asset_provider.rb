class RoadieNoExternalAssetProvider < Roadie::AssetPipelineProvider
  def find(name)
    if name == 'email'
      super
    else
      ''
    end
  end
end
