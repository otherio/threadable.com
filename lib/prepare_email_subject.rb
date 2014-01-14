# Encoding: UTF-8

class PrepareEmailSubject < MethodObject

  def call organization, email
    subject = email.subject.gsub(%r{\s*\[(#{Regexp.escape organization.subject_tag}|task|✔)\](\s*)}, '\2').sub(/^\s+/, '')
    return subject[0..254] if subject.present?
    split_body = email.stripped_plain.split(/\s+/)
    if split_body[8]
      subject = "#{split_body[0..7].join(' ').sub(/\W+$/, '')}..."
    else
      subject = split_body[0..7].join(' ').presence
    end
    subject.nil? ? nil : subject[0..251]
  end

end
