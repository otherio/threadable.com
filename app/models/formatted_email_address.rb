class FormattedEmailAddress

  def initialize options
    @address      = options[:address]
    @display_name = options[:display_name].to_s.strip
    @mail_address = Mail::Address.new(@address.to_s)
    @mail_address.display_name = @display_name if @display_name.present?
  end

  def to_s
    @mail_address.to_s
  end
  #      _         ;-.-._
  #   .-" "-.       \.  _{
  #  /       \      /   o )_
  # ;         |    ;  ,__(_<`  BAGOCK!
  # |        /     |     \()
  # |  /`\  (      |      ;
  #  \ \ |   '-..-';      |\
  #   '.;|   ,_ _.= \    /`|
  #      \  '.       '-'   |
  #       \   '=.         /
  #        '.     /     .'
  #          \  .'---';`
  #          | /  `.  |
  #         _||     `\\
  #        ` -.'-- .-'_'--.
  #            `"      `--
end
