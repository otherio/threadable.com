class IncomingEmail < ActiveRecord::Base
  attr_accessible :params
  serialize :params, IncomingEmail::Params
end
