ActionView::Template.register_template_handler(:rb, Class.new{
  def self.call(template)
    source = template.source.empty? ? File.read(template.identifier) : template.source
    code = "begin\n#{source}\nend"
    code += '.to_json' if template.formats.include? :json
    code
  end
})
