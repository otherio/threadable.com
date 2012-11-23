class Task < ActiveRecord::Base
  attr_accessible :done, :due_at, :name
end
