class Test::Api::Users

  extend Test::Api::Resources

  def self.find_by_id id
    all.find{|member| member[:id] == id }
  end

  def self.find_by_email email
    all.find{|member| member[:email] == email } || create(email: email)
  end

end
