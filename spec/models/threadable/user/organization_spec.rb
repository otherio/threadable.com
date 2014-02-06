# require 'spec_helper'

# describe Threadable::User::Organization do

#   let(:user)               { double :user }
#   let(:organizations)      { double :organizations, threadable: threadable, user: user }
#   let(:organization_record){ double :organization_record, id: 42, name: 'prepapre' }

#   subject{ described_class.new organizations, organization_record }

#   it { should be_a Threadable::Organization }
#   its(:organizations){ should be organizations }
#   its(:organization_record){ should be organization_record }
#   its(:user){ should be user }
#   its(:threadable){ should be threadable }
#   its(:inspect){ should eq %(#<#{described_class} organization_id: 42, name: "prepapre" for_user: #{user.inspect}>) }
#   its(:groups){ should be_a Threadable::User::Organization::Groups }

#   describe '#membership' do
#     let(:member){ double :member }
#     it 'should return the current users member' do
#       expect(subject.members).to receive(:me).and_return(member)
#       expect(subject.membership).to be member
#     end
#   end

#   describe '#leave!' do
#     it 'should return the current users member' do
#       expect(subject.members).to receive(:remove).with(user: user)
#       subject.leave!
#     end
#   end

# end
