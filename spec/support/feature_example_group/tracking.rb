module RSpec::Support::FeatureExampleGroup

  def mixpanel_distinct_id
    evaluate_script('mixpanel.get_distinct_id()')
  end

end
