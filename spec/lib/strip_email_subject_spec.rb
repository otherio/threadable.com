require 'spec_helper'

describe StripEmailSubject do

  delegate :call, to: :described_class

  let(:email_subject){ self.class.description }
  let(:project){ double(:project, subject_tag: 'foobar') }
  subject{ call(project, email_subject) }

  context "RE: [foobar] [walmart] where the kids at?" do
    it { should eq "RE: [walmart] where the kids at?" }
  end

  context "[✔] RE: [walmart] where the kids at?" do
    it { should eq "RE: [walmart] where the kids at?" }
  end

  context "[✔][foobar] RE: [walmart] where the kids at?" do
    it { should eq "RE: [walmart] where the kids at?" }
  end

  context "[task] RE: [walmart] where the kids at?" do
    it { should eq "RE: [walmart] where the kids at?" }
  end

  context "[walmart] where the [✔] kids at?" do
    it { should eq "[walmart] where the kids at?" }
  end

end
