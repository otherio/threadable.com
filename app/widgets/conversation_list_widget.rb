class ConversationListWidget < Rails::Widget::Presenter

  arguments :project

  options(
    conversations: ->(*){ locals[:project].conversations },
  )

end
