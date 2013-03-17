class TasksSidebarWidget < Rails::Widget::Presenter

  arguments :project

  options(
    conversations: ->(*){ locals[:project].conversations },
    tasks: ->(*){ locals[:project].tasks.includes(:doers) },
    my_tasks: ->(*){
      locals[:tasks].select{|task|
        task.doers.include? @view.current_user
      }
    },
    done_tasks:        ->(*){ locals[:tasks].select(&:done?) },
    not_done_tasks:    ->(*){ locals[:tasks].reject(&:done?) },
    my_done_tasks:     ->(*){ locals[:my_tasks].select(&:done?) },
    my_not_done_tasks: ->(*){ locals[:my_tasks].reject(&:done?) }
  )

end
