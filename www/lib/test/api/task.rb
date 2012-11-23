class Test::Api::Task

  include Virtus

  attribute :name, String
  attribute :project_name, String

  def self.create attributes
    @tasks ||= []
    task = new(attributes)
    @tasks << task
    task
  end

  def self.find project_name, name
    @tasks.find{|task|
      task.project_name == project_name && task.name == name
    }
  end

  def doers
    @doers ||= Doers.new(self)
  end

  def followers
    @followers ||= Followers.new(self)
  end

  class CollectionOfUsers < Struct.new(:task)

    def add user
      @users ||= []
      @users << user
    end

    attr_reader :user

  end

  class Doers < CollectionOfUsers
    def add user
      Test::Api::Emails.send({
        to: user.email,
        body: "you are totally a doer bro\n #{task.name} #{task.project_name}",
      })
      super user
    end
  end

  class Followers < CollectionOfUsers
    def add user
      Test::Api::Emails.send({
        to: user.email,
        body: "you are totally a follower yo!\n #{task.name} #{task.project_name}",
      })
      super user
    end
  end

end
