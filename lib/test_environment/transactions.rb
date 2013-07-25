module TestEnvironment::Transactions

  def test_transaction_open?
    @test_transaction_open
  end

  def begin_test_transaction!
    ActiveRecord::Base.connection.begin_transaction joinable: false
    @test_transaction_open = true
  end

  def end_test_transaction!
    ActiveRecord::Base.connection.rollback_transaction
    @test_transaction_open = false
  end

end
