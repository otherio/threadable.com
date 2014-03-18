class FormattedEmailAddress

  def initialize options
    @address      = to_ascii options[:address]
    @display_name = to_ascii options[:display_name]
    @mail_address = Mail::Address.new(@address)
    @mail_address.display_name = @display_name if @display_name.present?
  end

  def to_s
    @mail_address.to_s
  end

  private

  def to_ascii string
    string = string.to_s
    string = string.to_ascii if string =~ /[^\u0000-\u007F]/
    string.gsub(/\s+/, ' ').strip
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
