module Test::Api::Emails

  def self.reset!
    @emails = []
  end

  class << self
    attr_reader :emails
  end

  class Email
    include Virtus
    attribute :to, String
    # attribute :subject, String

    def self.send! user, task
      Test::Api::Emails.emails << new({
        user: user,
        task: task,
        to: user.email,
      })
    end

    def routes
      Rails.application.routes.url_helpers
    end
  end

  class YouAreNowADoerEmail < Email

    attribute :task
    attribute :user

    def subject
      "you are totally a doer bro!"
    end

    def body
      <<-HTML
        <html>
          <body>
            <p>#{subject}</p>
            <p>#{task.name}</p>
            <p>#{task.project_name}</p>
            <a href="#{routes.become_a_doer_project_task_url(task.project, task)}">do this task</a>
            <a href="#{routes.become_a_follower_project_task_url(task.project, task)}">just follow this task</a>
            <a href="#{routes.unsubscribe_project_task_url(task.project, task)}">unsubscribe</a>
        </body>
      </html>
      HTML
    end

  end

  class YouAreNowAFollowerEmail < Email

    attribute :task
    attribute :user

    def subject
      "you are totally a follower yo!"
    end

    def body
      <<-HTML
        <html>
          <body>
            <p>#{subject}</p>
            <p>#{task.name}</p>
            <p>#{task.project_name}</p>
            <a href="#{routes.become_a_follower_project_task_url(task.project, task)}">follow this task</a>
            <a href="#{routes.unsubscribe_project_task_url(task.project, task)}">unsubscribe</a>
        </body>
      </html>
      HTML
    end

  end

end
