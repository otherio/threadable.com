class WwwController < ApplicationController

  def index
    render nothing: true, layout: 'application'
  end

  SPECS = Rails.root.join('app/assets/javascripts/spec')
  PREFIX = Pathname.new('/assets/spec')

  # TEMP
  def spec
    @specs = []
    SPECS.find do |path|
      next unless path.to_s =~ /(.*)\.js$/
      @specs << (PREFIX + Pathname.new($1).relative_path_from(SPECS)).to_s
    end

    render nothing: true, layout: 'spec'
  end

end
