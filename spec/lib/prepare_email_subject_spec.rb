require 'spec_helper'

describe PrepareEmailSubject do

  delegate :call, to: :described_class

  let(:email_subject){ self.class.description }
  let(:organization){ double(:organization, subject_tag: 'foobar', groups: groups) }
  let(:groups) do
    double(:groups, all: [
      double(:group1, subject_tag: 'foobar+friends'),
      double(:group2, subject_tag: 'yourmom'),
    ])
  end
  let(:stripped_plain) { 'i am a message body' }
  let(:email) { double(:email, subject: email_subject, stripped_plain: stripped_plain ) }
  subject{ call(organization, email) }

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

  context "[foobar+friends] where the [✔] kids at?" do
    it { should eq "where the kids at?" }
  end

  context "[walmart][yourmom] where the [✔] kids at?" do
    it { should eq "[walmart] where the kids at?" }
  end

  context "[✔][foobar+friends][yourmom] RE: [walmart] where the kids at?" do
    it { should eq "RE: [walmart] where the kids at?" }
  end

  context "#{'a'*300}" do
    it { should eq 'a'*255 }
  end

  context 'without a subject' do
    context "[foobar] " do
      it { should eq "i am a message body" }
    end

    context "[✔][foobar] " do
      it { should eq "i am a message body" }
    end

    context " " do
      it { should eq "i am a message body" }
    end

    context "with a long message" do
      let(:stripped_plain) { "i've got a lovely bunch of coconuts. here, they are standing in a row. big ones, small ones, some as big as your head" }
      context "[foobar] " do
        it { should eq "i've got a lovely bunch of coconuts. here..." }
      end
    end

    context "with a very long word in the message" do
      let(:stripped_plain) { 'b'*300 }
      context "[foobar] " do
        it { should eq "#{'b'*252}" }
      end
    end

    context "with an empty message" do
      let(:stripped_plain) { '' }
      context "[foobar] " do
        it { should eq '(no subject)' }
      end

      context "[walmart]" do
        it { should eq "[walmart]" }
      end
    end

    context "with a nil message" do
      let(:stripped_plain) { nil }
      context "[foobar] " do
        it { should eq '(no subject)' }
      end

      context "[walmart]" do
        it { should eq "[walmart]" }
      end
    end
  end
end
