class IndexMessages < ActiveRecord::Migration
  def up
    Message.reindex!
  end
end
