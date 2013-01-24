class HtmlOptions < Hash

  def initialize hash=nil
    super()
    update(hash) if hash
  end

  def extractable_options?
    true
  end

  # used to make adding classnames to html_options hashes easier
  # usage
  #   html_options.add_classname class1, class2
  # examples
  #   html_options.add_classname('abc', 'def')
  #     => {:class => ['abc','def']}
  #   html_options.add_classname('def', 'ghi')
  #     => {:class => ['abc','def','ghi']}
  #   html_options.add_classname(['def', 'jkl'])
  #     => {:class => ['abc','def','ghi','jkl']}
  def add_classname(*new_classnames)
    self[:class] = Classnames.new + self[:class] + new_classnames
    self
  end

end
