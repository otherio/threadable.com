require 'rails/generators/named_base'

class Widgets::Generator < Rails::Generators::NamedBase

  source_root File.expand_path('../generator/templates', __FILE__)
  argument :name, :type => :string


end
