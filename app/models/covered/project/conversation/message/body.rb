class Covered::Project::Conversation::Message::Body < MethodObject

  def call html, plain
    case
    when html.present?
      html.html_safe.extend(HTML)
    when plain.present?
      plain.extend(Plain)
    else
      nil
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


end
