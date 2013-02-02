class Message < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :parent_message, :class_name => 'Message', :foreign_key => 'parent_id'
  belongs_to :user
  attr_accessible :body, :children, :message_id_header, :reply, :subject, :from, :user, :parent_message
end
