class MessageWidget < Widgets::Base

  def init message
    locals[:message] = message
  end

end
