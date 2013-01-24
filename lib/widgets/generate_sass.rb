class Widgets::GenerateSass
  def initialize(app)
    @app = app
  end

  def call(env)
    ::Widgets.generate_sass!
    @app.call(env)
  end
end
