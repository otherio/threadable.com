require 'spec_helper'

describe RunCommandsFromEmailMessageBody, :type => :request do

  delegate :call, to: :described_class

  let(:organization ){ current_user.organizations.find_by_slug! 'raceteam' }
  let(:task         ){ organization.tasks.find_by_slug! 'trim-body-panels' }
  let(:body         ){ "hi" }

  before do
    sign_in_as 'alice@ucsd.example.com'
  end

  def call!
    described_class.call(task, body)
  end

  context "with &done in the body" do
    let(:body) { "&done \nyo mama got this done last night." }

    it "marks the task as done" do
      expect(task.done?).to be_falsey
      call!
      expect(task.done?).to be_truthy
    end
  end

  context "with &undone in the body" do
    let(:task) { organization.tasks.find_by_slug! 'layup-body-carbon' }
    let(:body) { "&undone \nguys this is terrible. try again." }

    it "marks the task as undone" do
      expect(task.done?).to be_truthy
      call!
      expect(task.done?).to be_falsey
    end
  end

  context "with &mute in the body" do
    let(:body) { "&mute \nI am so tired of hearing this conversation. Muted." }

    it "marks the task as muted" do
      expect(task.muted?).to be_falsey
      call!
      expect(task.muted?).to be_truthy
    end
  end

  context "with &unmute in the body" do
    let(:body) { "&unmute \nOh god I didn't mean to mute this at all. I love you people!" }
    before do |variable|
      task.mute!
    end

    it "marks the task as unmuted" do
      expect(task.muted?).to be_truthy
      call!
      expect(task.muted?).to be_falsey
    end
  end

  context "with &follow in the body" do
    let(:body) { "&follow \nTime to follow this craziness." }

    it "marks the task as followed" do
      expect(task.followed?).to be_falsey
      expect(task).to receive :sync_to_user
      call!
      expect(task.followed?).to be_truthy
    end
  end

  context "with &unfollow in the body" do
    let(:body) { "&unfollow \nI am so tired of hearing this conversation. Unfollowed." }
    before do |variable|
      task.follow!
    end

    it "marks the task as unfollowed" do
      expect(task.followed?).to be_truthy
      call!
      expect(task.followed?).to be_falsey
    end
  end

  context "with &add My Name in the body" do
    let(:body) { "&add Alice Neilson \nI got this. I'm so ready to trim body panels." }

    it "adds Alice as a doer" do
      expect(task.doers.all.map(&:id)).to_not include current_user.id
      call!
      expect(task.doers.all.map(&:id)).to include current_user.id
    end
  end

  context "with &remove My Name in the body" do
    let(:body) { "&remove Tom Canver \nTom has decided that Carbon fiber is awful. Find an intern somewhere." }

    it "removes Tom as a doer" do
      tom = organization.members.find_by_email_address('tom@ucsd.example.com')
      expect(task.doers.all.map(&:id)).to include tom.id
      call!
      expect(task.doers.all.map(&:id)).to_not include tom.id
    end
  end

  context "with &remove My Name &mute in the beginning of the body" do
    let(:body) { "&remove Tom Canver \n&mute \nTom has decided that Carbon fiber is awful. Find an intern somewhere. Also, I'm so over this thread. Manage your own shit" }

    it "removes Tom as a doer, mutes the conversation" do
      tom = organization.members.find_by_email_address('tom@ucsd.example.com')
      expect(task.doers.all.map(&:id)).to include tom.id
      expect(task.muted?).to be_falsey
      call!
      expect(task.muted?).to be_truthy
      expect(task.doers.all.map(&:id)).to_not include tom.id
    end
  end

  context "with &remove My Name in the beginning of the body, and &mute after some text" do
    let(:body) { "&remove Tom Canver \nTom has decided that Carbon fiber is awful. Find an intern somewhere. \n&mute \nAlso, I'm so over this thread. Manage your own shit" }

    it "removes Tom as a doer, but doesn't mute the conversation" do
      tom = organization.members.find_by_email_address('tom@ucsd.example.com')
      expect(task.doers.all.map(&:id)).to include tom.id
      expect(task.muted?).to be_falsey
      call!
      expect(task.muted?).to be_falsey
      expect(task.doers.all.map(&:id)).to_not include tom.id
    end
  end





end
