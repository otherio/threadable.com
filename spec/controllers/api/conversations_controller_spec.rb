require 'spec_helper'

describe Api::ConversationsController do

  when_not_signed_in do
    describe 'index' do
      it 'renders unauthorized' do
        xhr :get, :index, format: :json, organization_id: 1
        expect(response.status).to eq 401
      end
    end
    describe 'create' do
      it 'renders unauthorized' do
        xhr :post, :create, format: :json, organization_id: 1
        expect(response.status).to eq 401
      end
    end
    describe 'show' do
      it 'renders unauthorized' do
        xhr :get, :show, format: :json, organization_id: 1, id: 1
        expect(response.status).to eq 401
      end
    end
    describe 'update' do
      it 'renders unauthorized' do
        xhr :patch, :update, format: :json, organization_id: 1, id: 1
        expect(response.status).to eq 401
      end
    end
  end

  when_signed_in_as 'bob@ucsd.example.com' do

    let(:raceteam){ covered.organizations.find_by_slug! 'raceteam' }
    let(:sfhealth){ covered.organizations.find_by_slug! 'sfhealth' }
    let(:conversations) { }

    # get /api/:organization_id/conversations
    describe 'index' do

      let :params do
        {
          format: :json,
          organization_id: organization_id,
          context: context,
          scope: scope,
          group_id: group_id,
        }
      end

      let(:organization_id){ 'raceteam' }
      let(:context)        { 'my' }
      let(:scope)          { 'not_muted_conversations' }
      let(:group_id)       { nil }

      def request!
        xhr :get, :index, params
      end

      context 'when not given an organization id' do
        let(:organization_id){ nil }
        it 'renders not acceptable' do
          request!
          expect(response.status).to eq 406
        end
      end

      context 'when not given a context' do
        let(:context){ nil }
        it 'renders not acceptable' do
          request!
          expect(response.status).to eq 406
        end
      end

      context 'when not given a scope' do
        let(:scope){ nil }
        it 'renders not acceptable' do
          request!
          expect(response.status).to eq 406
        end
      end

      context 'when not given an invalid context' do
        let(:context){ 'poop' }
        it 'renders not acceptable' do
          request!
          expect(response.status).to eq 406
        end
      end

      context 'when not given an invalid scope' do
        let(:scope){ 'cookies' }
        it 'renders not acceptable' do
          request!
          expect(response.status).to eq 406
        end
      end

      context 'when given an invalid organization id' do
        let(:organization_id){ 'h834jh54h54h534h' }
        it 'renders not found' do
          request!
          expect(response.status).to eq 404
        end
      end

      context 'when given the context "group" but not given a group id' do
        let(:context){ 'group' }
        let(:group_id){ nil }
        it "renders not acceptable" do
          request!
          expect(response.status).to eq 406
        end
      end

      context 'when given a valid organization id' do
        let(:organization_id){ 'raceteam' }

        let(:organization)       { double(:organization) }
        let(:collection)         { double(:collection) }
        let(:organization_groups){ double(:organization_groups)   }
        let(:group)              { double(:group) }
        let(:stub_chain)         { [] }

        before do
          expect(current_user.organizations).to receive(:find_by_slug!).with(organization_id).and_return(organization)
          if context == 'group'
            expect(organization).to receive(:groups).and_return(organization_groups)
            expect(organization_groups).to receive(:find_by_email_address_tag!).with(group_id).and_return(group)
            group.stub_chain(*stub_chain).and_return(collection)
          else
            organization.stub_chain(*stub_chain).and_return(collection)
          end
          expect(controller).to receive(:serialize).with(:conversations, collection).and_return({conversations: []})
          request!
          expect(response.status).to eq 200
        end

        context 'when given the context "my"' do
          let(:context){ 'my' }
          context 'and the scope "not_muted_conversations"' do
            let(:scope){ 'not_muted_conversations'}
            let(:stub_chain){ [:conversations, :my, :not_muted] }
            it "calls organization.conversations.my.not_muted" do
            end
          end
          context 'and the scope "muted_conversations"' do
            let(:scope){ 'muted_conversations'}
            let(:stub_chain){ [:conversations, :my, :muted] }
            it "calls organization.conversations.my.muted" do
            end
          end
          context 'and the scope "all_task"' do
            let(:scope){ 'all_task'}
            let(:stub_chain){ [:tasks, :my, :all] }
            it "calls organization.tasks.my.all" do
            end
          end
          context 'and the scope "doing_tasks"' do
            let(:scope){ 'doing_tasks'}
            let(:stub_chain){ [:tasks, :my, :doing] }
            it "calls organization.tasks.my.doing" do
            end
          end
        end

        context 'when given the context "ungrouped"' do
          let(:context){ 'ungrouped' }
          context 'and the scope "not_muted_conversations"' do
            let(:scope){ 'not_muted_conversations'}
            let(:stub_chain){ [:conversations, :ungrouped, :not_muted] }
            it "calls organization.conversations.ungrouped.not_muted" do
            end
          end
          context 'and the scope "muted_conversations"' do
            let(:scope){ 'muted_conversations'}
            let(:stub_chain){ [:conversations, :ungrouped, :muted] }
            it "calls organization.conversations.ungrouped.muted" do
            end
          end
          context 'and the scope "all_task"' do
            let(:scope){ 'all_task'}
            let(:stub_chain){ [:tasks, :ungrouped, :all] }
            it "calls organization.tasks.ungrouped.all" do
            end
          end
          context 'and the scope "doing_tasks"' do
            let(:scope){ 'doing_tasks'}
            let(:stub_chain){ [:tasks, :ungrouped, :doing] }
            it "calls organization.tasks.ungrouped.doing" do
            end
          end

        end

        context 'when given the context "group"' do
          let(:context){ 'group' }
          let(:group_id){ 'electronics' }
          context 'and the scope "not_muted_conversations"' do
            let(:scope){ 'not_muted_conversations'}
            let(:stub_chain){ [:conversations, :not_muted] }
            it "calls group.conversations.not_muted" do
            end
          end
          context 'and the scope "muted_conversations"' do
            let(:scope){ 'muted_conversations'}
            let(:stub_chain){ [:conversations, :muted] }
            it "calls group.conversations.muted" do
            end
          end
          context 'and the scope "all_task"' do
            let(:scope){ 'all_task'}
            let(:stub_chain){ [:tasks, :all] }
            it "calls group.tasks.all" do
            end
          end
          context 'and the scope "doing_tasks"' do
            let(:scope){ 'doing_tasks'}
            let(:stub_chain){ [:tasks, :doing] }
            it "calls group.tasks.doing" do
            end
          end
        end

      end
    end

    # post /api/:organization_id/conversations
    describe 'create' do
      context 'when given valid conversation data' do
        it 'creates and returns the new conversation' do
          xhr :post, :create, format: :json, organization_id: raceteam.slug, conversation: { subject: 'my conversation' }
          expect(response.status).to eq 201
          conversation = raceteam.conversations.find_by_slug('my-conversation')
          expect(conversation).to be
          expect(response.body).to eq serialize(:conversations, conversation).to_json
        end
      end

      context 'with an organization that the user is not a member of' do
        it 'renders a 404' do
          xhr :post, :create, format: :json, organization_id: sfhealth.slug, conversation: { subject: 'my conversation' }
          expect(response.status).to eq 404
        end
      end

      context 'with no subject' do
        it 'returns a param not found error' do
          xhr :post, :create, format: :json, organization_id: raceteam.slug, conversation: {  }
          expect(response.status).to eq 406
          expect(response.body).to eq '{"error":"param not found: conversation"}'
        end
      end

      context 'with a blank subject' do
        it 'returns a param not found error' do
          xhr :post, :create, format: :json, organization_id: raceteam.slug, conversation: { subject: '' }
          expect(response.status).to eq 406
          expect(response.body).to eq '{"error":"param not found: subject"}'
        end
      end
    end

    # get /api/:organization_id/:id
    describe 'show' do
      # context 'when given a valid organization id' do
      #   it "should render the current users's organizations as json" do
      #     xhr :get, :show, format: :json, id: raceteam.id
      #     expect(response).to be_ok
      #     expect(response.body).to eq Api::OrganizationsSerializer[raceteam].to_json
      #   end
      # end
      # context 'when given an invalid organization id' do
      #   it "should render the current users's organizations as json" do
      #     xhr :get, :show, format: :json, id: 32843874832
      #     expect(response.status).to eq 404
      #     expect(response.body).to eq '{"error":"Unauthorized"}'
      #   end
      # end
    end

    # patch /api/:organization_id/:id
    describe 'update' do
      context 'when given done/not done conversation data' do
        it 'marks the conversation as done/not done' do
          xhr :put, :update, format: :json, organization_id: raceteam.slug, id: 'layup-body-carbon', conversation: { done: false }
          expect(response.status).to eq 200
          conversation = raceteam.conversations.find_by_slug('layup-body-carbon')
          expect(conversation).to_not be_done
          expect(response.body).to eq serialize(:conversations, conversation).to_json

          xhr :put, :update, format: :json, organization_id: raceteam.slug, id: 'layup-body-carbon', conversation: { done: true }
          expect(response.status).to eq 200
          conversation = raceteam.conversations.find_by_slug('layup-body-carbon')
          expect(conversation).to be_done
          expect(response.body).to eq serialize(:conversations, conversation).to_json
        end
      end

      context 'when given doers' do
        let(:alice) { raceteam.members.find_by_email_address('alice@ucsd.example.com')}
        let(:tom)   { raceteam.members.find_by_email_address('tom@ucsd.example.com')}
        let(:yan)   { raceteam.members.find_by_email_address('yan@ucsd.example.com')}
        it 'sets the doers' do
          xhr :put, :update, format: :json, organization_id: raceteam.slug, id: 'layup-body-carbon', conversation: {
            doers: [{id: alice.id}, {id: tom.id}, {id: "#{yan.id}"}]
          }
          expect(response.status).to eq 200
          conversation = raceteam.conversations.find_by_slug('layup-body-carbon')
          expect(conversation.doers.all.map(&:id)).to match_array [alice.id, tom.id, yan.id]
          expect(conversation.events.all.length).to eq(5)
        end
      end

      context 'when given empty doers' do
        it 'sets the doers' do
          xhr :put, :update, format: :json, organization_id: raceteam.slug, id: 'layup-body-carbon', conversation: {
            doers: nil
          }
          expect(response.status).to eq 200
          conversation = raceteam.conversations.find_by_slug('layup-body-carbon')
          expect(conversation.doers.all.length).to eq 0
          expect(conversation.events.all.length).to eq(6)
        end
      end

      context 'when given mute/unmute' do
        it 'mutes and unmutes the conversation' do
          xhr :put, :update, format: :json, organization_id: raceteam.slug, id: 'layup-body-carbon', conversation: {
            muted: true
          }
          expect(response.status).to eq 200
          conversation = raceteam.conversations.find_by_slug('layup-body-carbon')
          expect(conversation.muted?).to be_true
        end
      end

      context 'with an organization that the user is not a member of' do
        it 'renders a 404' do
          xhr :put, :update, format: :json, organization_id: sfhealth.slug, id: 'review-our-intake-policies', conversation: { done: true }
          expect(response.status).to eq 404
        end
      end

      context 'with a conversation that does not exist' do
        it 'renders a 404' do
          xhr :put, :update, format: :json, organization_id: raceteam.slug, id: 'babys-first-task', conversation: { done: true }
          expect(response.status).to eq 404
        end
      end
    end

    # delete /api/:organization_id/:id
    describe 'destroy' do

    end

  end


end
