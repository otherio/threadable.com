require 'algoliasearch-rails'
[
  AlgoliaSearch::ClassMethods,
  AlgoliaSearch::ClassMethods::AdditionalMethods,
  AlgoliaSearch::InstanceMethods,
].each do |_module|
  _module.instance_methods.each do |method_name|
    _module.send(:define_method, method_name){|*args, &block|}
  end
end
