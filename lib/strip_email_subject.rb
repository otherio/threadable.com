class StripEmailSubject < MethodObject

  def call project, subject
    subject.gsub(%r{\s*\[(#{Regexp.escape project.subject_tag}|task|✔)\](\s*)}, '\2').sub(/^\s+/, '')
  end

end
