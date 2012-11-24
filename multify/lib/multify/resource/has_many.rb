class Multify::Resource::HasMany

  def initialize model, options={}
    @model, @options = model, options
  end

  def find options={}
    @model.find(@options.merge(options))
  end

  def new attributes={}
    @model.new(@options.merge(attributes))
  end

end
