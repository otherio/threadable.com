require 'spec_helper'

describe OrganizationMembership do

  it { should belong_to :user }
  it { should belong_to :organization }
  it { should have_many :email_addresses }
  it { should validate_presence_of :organization_id }
  it { should validate_presence_of :user_id }
  # it { should ensure_inclusion_of(:gets_email).in_array([true, false]) }
  it { should ensure_inclusion_of(:ungrouped_conversations).in_array([0,1,2]) }


  let(:organization_id)        { 1 }
  let(:user_id)                { 1 }
  let(:gets_email)             { true }
  let(:ungrouped_conversations){ 0 }

  def attributes
    {
      organization_id:         organization_id,
      user_id:                 user_id,
      gets_email:              gets_email,
      ungrouped_conversations: ungrouped_conversations,
    }
  end

  subject{ OrganizationMembership.create!(attributes) }

  it 'should get ungrouped conversations by default' do
    expect(described_class.new.ungrouped_conversations).to eq 1
    expect(described_class.new.gets_ungrouped_conversation_messages?).to be_true
  end


  context 'when ungrouped_conversations is 0' do
    let(:ungrouped_conversations){ 0 }
    its(:gets_no_ungrouped_conversation_mail?    ){ should be_true  }
    its(:gets_ungrouped_conversation_messages?   ){ should be_false }
    its(:gets_ungrouped_conversations_in_summary?){ should be_false }
  end
  context 'when ungrouped_conversations is 1' do
    let(:ungrouped_conversations){ 1 }
    its(:gets_no_ungrouped_conversation_mail?    ){ should be_false }
    its(:gets_ungrouped_conversation_messages?   ){ should be_true  }
    its(:gets_ungrouped_conversations_in_summary?){ should be_false }
  end
  context 'when ungrouped_conversations is 2' do
    let(:ungrouped_conversations){ 2 }
    its(:gets_no_ungrouped_conversation_mail?    ){ should be_false }
    its(:gets_ungrouped_conversation_messages?   ){ should be_false }
    its(:gets_ungrouped_conversations_in_summary?){ should be_true  }
  end

  describe 'gets_no_ungrouped_conversation_mail!' do
    let(:ungrouped_conversations){ 2 }
    it 'sets ungrouped_conversations to 0' do
      expect(subject.ungrouped_conversations).to eq 2
      subject.gets_no_ungrouped_conversation_mail!
      expect(subject.ungrouped_conversations).to eq 0
    end
  end
  describe 'gets_ungrouped_conversation_messages!' do
    let(:ungrouped_conversations){ 0 }
    it 'sets ungrouped_conversations to 1' do
      expect(subject.ungrouped_conversations).to eq 0
      subject.gets_ungrouped_conversation_messages!
      expect(subject.ungrouped_conversations).to eq 1
    end
  end
  describe 'gets_ungrouped_conversations_in_summary!' do
    let(:ungrouped_conversations){ 1 }
    it 'sets ungrouped_conversations to 2' do
      expect(subject.ungrouped_conversations).to eq 1
      subject.gets_ungrouped_conversations_in_summary!
      expect(subject.ungrouped_conversations).to eq 2
    end
  end

end
