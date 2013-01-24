class FlashMessagesWidget < Widgets::Base

  def init
    locals[:flash_messages] = @view.flash.map
  end

end
