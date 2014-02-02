require_dependency 'threadable/message'

class Threadable::Message::Body < MethodObject

  def call html, plain
    case
    when html.present?
      html.html_safe.extend(HTML)
    when plain.present?
      plain.extend(Plain)
    else
      ''.extend(Empty)
    end
  end

  module HTML
    def html?
      true
    end
  end

  module Plain
    def html?
      false
    end
  end

  module Empty
    def html?
      false
    end
  end


end
