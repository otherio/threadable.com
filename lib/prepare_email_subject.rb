# Encoding: UTF-8

class PrepareEmailSubject < MethodObject

  def call organization, email
    possible_subject_tags = organization.groups.all.map(&:subject_tag)
    possible_subject_tags << organization.subject_tag
    possible_subject_tags = possible_subject_tags.map{|tag| Regexp.escape tag}.join('|')
    subject = email.subject.gsub(%r{\s*\[(#{possible_subject_tags}|task|✔|✔\uFE0E|✔\uFE0F)\](\s*)}, '\2').sub(/^\s+/, '')
    return subject[0..254] if valid_subject?(subject)
    return nil unless email.stripped_plain
    split_body = email.stripped_plain.split(/\s+/)
    if split_body[8]
      subject = "#{split_body[0..7].join(' ').sub(/\W+$/, '')}..."
    else
      subject = split_body[0..7].join(' ').presence
    end
    valid_subject?(subject) ? subject[0..251] : nil
  end

  private

  def valid_subject?(subject)
    subject.present? && subject.to_url.present?
  end

end
