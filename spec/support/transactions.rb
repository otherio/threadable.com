module RSpec::Support::Transactions

  def self.test_transaction_open?
    !!@test_transaction_open
  end

  def self.ensure_no_open_transactions!
    raise "a transaction should not be open" if ActiveRecord::Base.connection.transaction_open?
  end

  def self.rollback_transactions!
    while ActiveRecord::Base.connection.transaction_open?
      ActiveRecord::Base.connection.rollback_transaction
    end
  end

  def self.open_test_transaction!
    raise "test transaction already open" if test_transaction_open?
    ensure_no_open_transactions!
    ActiveRecord::Base.connection.begin_transaction joinable: false
    @test_transaction_open = true
  end

  def self.rollback_test_transaction!
    raise "test transaction is not open" unless test_transaction_open?
    rollback_transactions!
    @test_transaction_open = false
  end

  delegate :ensure_no_open_transactions!, :test_transaction_open?, to: self

  def test_transaction
    RSpec::Support::Transactions.open_test_transaction!
    begin
      yield
    ensure
      RSpec::Support::Transactions.rollback_test_transaction!
    end
  end

  RSpec.configure do |config|
    config.backtrace_exclusion_patterns += [/support\/transactions/]
  end

end
