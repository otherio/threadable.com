# We need to be able to schedule background jobs within sql transactions
# that only get scheduled if the outer most transaction is commited
# these module extend ::Threadable to allow for after_transaction callbacks
module Threadable::Transactions

  class << self
    attr_accessor :expect_test_transaction, :in_migration
  end

  def transactions
    Thread.current['threadable.transactions'] ||= []
  end

  def transaction_open?
    # this is production code that knows when its being tested. Awesome right? ::facepalm::
    if Threadable::Transactions.expect_test_transaction && RSpec::Support::Transactions.test_transaction_open?
      ActiveRecord::Base.connection.open_transactions > 1
    elsif Threadable::Transactions.in_migration
      ActiveRecord::Base.connection.open_transactions > 1
    else
      ActiveRecord::Base.connection.open_transactions > 0
    end
  end

  def transaction &block
    raise "another outside transaction is already open" if transaction_open? && transactions.empty?
    transactions << []
    begin
      postgres.within_new_transaction(&block)
    rescue Exception => exception
      raise exception
    ensure # we need to do everything in an esure because explicit returns skip code beyond the postgres.transaction(&block) call
      if exception
        transactions.pop # do not call any callbacks for this failed transaction
      else
        # run each transaction callback in FIFO order if we're the last open transaction
        transactions.shift.each(&:call) until transactions.empty? unless transaction_open?
      end
    end
  end

  def after_transaction(&block)
    if transaction_open?
      transactions.last << block
    else
      yield
    end
  end

end
