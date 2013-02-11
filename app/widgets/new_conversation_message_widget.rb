class NewConversationMessageWidget < Rails::Widget::Presenter

  arguments :conversation

  options(
    from: ->(*){ @view.current_user },
  )

end
