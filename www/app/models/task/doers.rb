class Task::Doers < CollectionOfUsers

  def add user
    super user
    Api::Emails::YouAreNowADoerEmail.send!(user, task)
  end

end
