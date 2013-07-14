class IncomingEmail < ActiveRecord::Base
  serialize :params, IncomingEmail::Params
end
