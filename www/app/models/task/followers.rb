class Task::Followers < CollectionOfUsers

  def add user
    super user
    Api::Emails::YouAreNowAFollowerEmail.send!(user, task)
  end

end
