class CollectionOfUsers < Struct.new(:task)

  def add user
    @users ||= []
    @users << user
  end

  attr_reader :users

end
