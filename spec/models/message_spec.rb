require 'spec_helper'

describe Message do
  it { should belong_to(:parent_message) }
  it { should belong_to(:conversation) }

  [:body, :children, :message_id_header, :reply, :subject, :from, :user, :parent_message].each do |attr|
    it { should allow_mass_assignment_of(attr) }
  end
end
