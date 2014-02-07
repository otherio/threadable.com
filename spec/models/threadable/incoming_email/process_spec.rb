require 'spec_helper'

describe Threadable::IncomingEmail::Process do

  let(:deliverable) { false }
  let(:holdable)    { false }
  let(:bounceable)  { false }
  let(:droppable)   { false }
  let(:current_user){ nil }

  let :incoming_email do
    double(:incoming_email,
      id: 9931,
      threadable: double(:threadable, current_user: current_user),
      conversation: double(:conversation),
      stripped_plain: 'foo',
      deliverable?: deliverable,
      holdable?: holdable,
      bounceable?: bounceable,
      droppable?: droppable,
      message: nil,
      deliver!: nil,
    )
  end

  def call!
    described_class.call(incoming_email)
  end

  context 'when the incoming email has already been processed' do
    before{ incoming_email.stub :processed? => true }
    it 'raises an ArgumentError' do
      expect{ call! }.to raise_error(ArgumentError, 'IncomingEmail 9931 has already been processed')
    end
  end

  context 'when the incoming email has not been processed' do
    before do
      incoming_email.stub :processed? => false
      expect(Threadable).to receive(:transaction).and_yield
      expect(incoming_email).to receive(:find_organization!)
      expect(incoming_email).to receive(:find_groups!)
    end
    context 'and the organization or groups are not found' do
      before do
        expect(incoming_email).to receive(:bounceable?).and_return(true)
      end
      it 'bounces the incoming email' do
        expect(incoming_email).to receive(:bounce!)
        expect(incoming_email).to receive(:processed!)
        call!
      end
    end
    context 'and the organization and groups are found' do
      before do
        expect(incoming_email).to receive(:bounceable?).twice.and_return(false)
        expect(incoming_email).to receive(:find_message!)
        expect(incoming_email).to receive(:find_creator!)
        expect(incoming_email).to receive(:find_parent_message!)
        expect(incoming_email).to receive(:find_conversation!)
      end
      context 'and the incoming_email is deliverable' do
        let(:deliverable) { true }
        before do
          expect(incoming_email).to receive(:processed!)
        end
        context 'and the creator is found' do
          before{ expect(incoming_email).to receive(:creator).and_return(double(:creator, id: 94)) }
          it 'signs in as the creator' do
            expect(incoming_email.threadable).to receive(:current_user_id=).with(94)
            call!
          end
          context 'and the message is not a duplicate' do
            let(:current_user) { double(:current_user) }
            before{ expect(incoming_email).to receive(:message).and_return(nil) }
            it 'runs the commands' do
              expect(incoming_email.threadable).to receive(:current_user_id=).with(94)
              expect(RunCommandsFromEmailMessageBody).to receive(:call).
                with(incoming_email.conversation, incoming_email.stripped_plain)
              call!
            end
          end

          context 'and the message is a duplicate' do
            let(:current_user) { double(:current_user) }
            before do
              expect(incoming_email.threadable).to receive(:current_user_id=).with(94)
              expect(incoming_email).to receive(:message).and_return(double(:message))
            end

            it 'does not run the commands' do
              expect(RunCommandsFromEmailMessageBody).to_not receive(:call)
              call!
            end

            context 'and the message is deliverable' do
              let(:deliverable) { true }
              it 'does not deliver the mail' do
                expect(incoming_email).to_not receive(:deliver!)
                call!
              end
            end

            context 'and the message is holdable' do
              let(:holdable) { true }
              it 'does not hold the mail' do
                expect(incoming_email).to_not receive(:hold!)
                call!
              end
            end
          end
        end

        context 'and the creator is not found' do
          before{ expect(incoming_email).to receive(:creator).and_return(nil) }
          it 'signs out' do
            expect(incoming_email.threadable).to receive(:current_user_id=).with(nil)
            expect(RunCommandsFromEmailMessageBody).to_not receive(:call)
            call!
          end
        end
      end

      context 'and the incoming_email is not deliverable' do
        let(:deliverable) { false }
        before do
          expect(incoming_email).to receive(:creator).and_return(double(:creator, id: 94))
          expect(incoming_email.threadable).to receive(:current_user_id=).with(94)
        end
        context 'and the incoming_email is holdable' do
          before{ expect(incoming_email).to receive(:holdable?).once.and_return(true) }
          it 'holds the incoming email' do
            expect(incoming_email).to receive(:hold!)
            expect(incoming_email).to receive(:processed!)
            expect(RunCommandsFromEmailMessageBody).to_not receive(:call)
            call!
          end
        end

        context 'and the incoming_email is droppable' do
          let(:droppable) { true }

          context 'and the creator is found' do
            let(:current_user) {double(:current_user)}
            before do
              expect(incoming_email).to receive(:drop!)
              expect(incoming_email).to receive(:processed!)
            end
            it 'runs the commands' do
              expect(RunCommandsFromEmailMessageBody).to receive(:call).
                with(incoming_email.conversation, incoming_email.stripped_plain)
              call!
            end
          end
          context 'and the creator is not found' do
            before do
              expect(incoming_email).to receive(:drop!)
              expect(incoming_email).to receive(:processed!)
            end
            it 'does not run the commands' do
              expect(RunCommandsFromEmailMessageBody).to_not receive(:call)
              call!
            end
          end
        end
      end
    end
  end

end
