require 'spec_helper'

describe EmailActionsController, :type => :controller do
  include EmberRouteUrlHelpers

  describe '#take' do
    let(:user){ threadable.users.find_by_email_address!('bethany@ucsd.example.com') }
    let(:organization){ user.organizations.find_by_slug!('raceteam') }

    when_not_signed_in do
      context 'with secure buttons disabled' do
        describe 'mute' do
          let(:conversation){ organization.conversations.find_by_slug!('drive-trains-are-expensive') }
          let(:token){ EmailActionToken.encrypt(conversation.id, user.id, 'mute') }

          it 'mutes the conversation' do
            patch :take, token: token
            expect(response).to be_success
            conversation.reload
            expect(conversation).to be_muted_by user
          end

          context 'with a private group conversation' do
            let(:user){ threadable.users.find_by_email_address!('tom@ucsd.example.com') }
            let(:conversation_record) { ::Conversation.where(slug: 'recruiting').first }
            let(:conversation) do
              conversation = Threadable::Conversation.new(threadable, conversation_record)
              conversation.organization = organization
              conversation
            end

            it 'mutes the conversation' do
              patch :take, token: token
              expect(response).to be_success
              conversation.reload
              expect(conversation).to be_muted_by user
            end
          end
        end
      end

      context 'with secure buttons enabled' do
        before do
          user.update(secure_mail_buttons: true)
        end

        describe 'mute' do
          let(:conversation){ organization.conversations.find_by_slug!('drive-trains-are-expensive') }
          let(:token){ EmailActionToken.encrypt(conversation.id, user.id, 'mute') }

          it 'renders pending' do
            patch :take, token: token
            expect(response).to render_template :pending
            conversation.reload
            expect(conversation).to_not be_muted_by user
          end
        end
      end
    end

    when_signed_in_as 'bethany@ucsd.example.com' do
      describe 'mute' do
        let(:conversation){ organization.conversations.find_by_slug!('drive-trains-are-expensive') }
        let(:token){ EmailActionToken.encrypt(conversation.id, user.id, 'mute') }

        it 'mutes the conversation' do
          patch :take, token: token
          expect(response).to redirect_to conversation_url(organization, 'my', conversation, success: "You muted \"#{conversation.subject}\"")
          conversation.reload
          expect(conversation).to be_muted_by user
        end
      end
    end

  end



end
