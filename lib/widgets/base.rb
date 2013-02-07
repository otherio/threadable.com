class Widgets::Base

  Paths = Struct.new(
    :class,
    :class_spec,
    :partial,
    :partial_spec,
    :javascript,
    :javascript_spec,
    :sass,
    :example,
  )
  def self.paths
    path = Rails.root.method(:join).to_proc
    Paths.new(
      path["app/widgets/#{classname}_widget.rb"],
      path["spec/widgets/#{classname}_widget_spec.rb"],
      path["app/views/widgets/#{classname}.html.haml"],
      path["spec/views/widgets/#{classname}_spec.rb"],
      path["app/assets/javascripts/widgets/#{classname}.js"],
      path["spec/javascripts/widgets/#{classname}_spec.js"],
      path["app/assets/stylesheets/widgets/_#{classname}.sass"],
      path["app/views/development/styleguide/widgets/_#{classname}.sass"],
    )
  end

  def self.render *arguments, &block
    new(*arguments, &block).render
  end

  def self.classname
    self.name.to_s.sub(/Widget$/,'').underscore
  end

  def initialize view, *arguments, &block
    @view           = view
    @arguments      = arguments
    @block          = block
    @html_options   = HtmlOptions.new arguments.extract_options!
    default_options = send(:default_options) # so we dont call the method twice
    @options, @html_options = @html_options, @html_options.slice!(*default_options.keys)
    @options.reverse_merge!(default_options)
    @html_options.add_classname(self.classname)
    init *@arguments
    locals.merge!(@options)
  end

  attr_reader :view, :block, :html_options

  delegate :classname, :to => 'self.class'

  def self.node_type node_type=nil
    @node_type = node_type unless node_type.nil?
    @node_type || :div
  end

  def init *arguments
  end

  def locals
    @locals ||= {}
  end

  def default_options
    {}
  end

  def render
    @view.capture do
      @view.haml_tag(self.class.node_type, html_options) do
        @view.concat begin
          @view.render(partial: "widgets/#{classname}", locals: locals, &block)
        rescue ActionView::MissingTemplate
          @view.render(partial: "widgets/#{classname}.html", locals: locals, &block)
        end
      end
    end
  end

end
