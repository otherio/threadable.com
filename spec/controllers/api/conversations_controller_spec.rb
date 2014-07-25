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

    let(:raceteam){ threadable.organizations.find_by_slug! 'raceteam' }
    let(:sfhealth){ threadable.organizations.find_by_slug! 'sfhealth' }
    let(:conversations) { }

    # get /api/:organization_id/conversations
    describe 'index' do

      let :params do
        {
          format: :json,
          organization: organization,
          group: group,
          scope: scope,
          group: group,
          page:  page,
        }
      end

      let(:organization){ 'raceteam' }
      let(:group)       { 'my' }
      let(:scope)       { 'not_muted_conversations' }
      let(:page)        { 0 }

      def request!
        xhr :get, :index, params
      end

      context 'when not given an organization id' do
        let(:organization){ nil }
        it 'renders not acceptable' do
          request!
          expect(response.status).to eq 406
        end
      end

      context 'when not given a group' do
        let(:group){ nil }
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

      context 'when not given a page' do
        let(:page){ nil }
        it 'renders not acceptable' do
          request!
          expect(response.status).to eq 406
        end
      end

      context 'when given an invalid group' do
        let(:group){ 'poop' }
        it 'renders not acceptable' do
          request!
          expect(response.status).to eq 404
        end
      end

      context 'when given an invalid scope' do
        let(:scope){ 'cookies' }
        it 'renders not acceptable' do
          request!
          expect(response.status).to eq 406
        end
      end

      context 'when given an invalid organization id' do
        let(:organization){ 'h834jh54h54h534h' }
        it 'renders not found' do
          request!
          expect(response.status).to eq 404
        end
      end

      context 'when given a valid organization' do
        let(:organization){ 'raceteam' }
        let(:organization_double) { double(:organization) }
        let(:conversations_double){ double(:conversations) }

        context 'and the group "my"' do
          let(:group){ 'my' }

          let(:my_double){ double :my }
          before do
            expect(current_user.organizations).to receive(:find_by_slug!).with(organization).and_return(organization_double)
            expect(organization_double).to receive(:my).and_return(my_double)
            expect(my_double).to receive(scope.to_sym).with(page).and_return(conversations_double)
            expect(controller).to receive(:serialize).with(:conversations, conversations_double).and_return({conversations: []})
            request!
            expect(response.status).to eq 200
          end

          context 'and the scope "muted_conversations"' do
            let(:scope){ 'muted_conversations' }
            it 'calls organization.muted_conversations' do
            end
          end
          context 'and the scope "not_muted_conversations"' do
            let(:scope){ 'not_muted_conversations' }
            it 'calls organization.not_muted_conversations' do
            end
          end
          context 'and the scope "done_tasks"' do
            let(:scope){ 'done_tasks' }
            it 'calls organization.done_tasks' do
            end
          end
          context 'and the scope "not_done_tasks"' do
            let(:scope){ 'not_done_tasks' }
            it 'calls organization.not_done_tasks' do
            end
          end
          context 'and the scope "done_doing_tasks"' do
            let(:scope){ 'done_doing_tasks' }
            it 'calls organization.done_doing_tasks' do
            end
          end
          context 'and the scope "not_done_doing_tasks"' do
            let(:scope){ 'not_done_doing_tasks' }
            it 'calls organization.not_done_doing_tasks' do
            end
          end
        end

        context 'and the group "trash"' do
          let(:group){ 'trash' }

          let(:trash_double){ double :trash }
          before do
            expect(current_user.organizations).to receive(:find_by_slug!).with(organization).and_return(organization_double)
            expect(organization_double).to receive(:trash).and_return(trash_double)
            expect(trash_double).to receive(scope.to_sym).with(page).and_return(conversations_double)
            expect(controller).to receive(:serialize).with(:conversations, conversations_double).and_return({conversations: []})
            request!
            expect(response.status).to eq 200
          end

          context 'and the scope "muted_conversations"' do
            let(:scope){ 'muted_conversations' }
            it 'calls organization.muted_conversations' do
            end
          end
          context 'and the scope "not_muted_conversations"' do
            let(:scope){ 'not_muted_conversations' }
            it 'calls organization.not_muted_conversations' do
            end
          end
          context 'and the scope "done_tasks"' do
            let(:scope){ 'done_tasks' }
            it 'calls organization.done_tasks' do
            end
          end
          context 'and the scope "not_done_tasks"' do
            let(:scope){ 'not_done_tasks' }
            it 'calls organization.not_done_tasks' do
            end
          end
          context 'and the scope "done_doing_tasks"' do
            let(:scope){ 'done_doing_tasks' }
            it 'calls organization.done_doing_tasks' do
            end
          end
          context 'and the scope "not_done_doing_tasks"' do
            let(:scope){ 'not_done_doing_tasks' }
            it 'calls organization.not_done_doing_tasks' do
            end
          end
        end

        context 'and the group is a group name' do
          let(:group){ 'electronics' }

          let(:group_double){ double :group }
          before do
            expect(current_user.organizations).to receive(:find_by_slug!).with(organization).and_return(organization_double)
            groups_double = double :groups
            expect(organization_double).to receive(:groups).and_return(groups_double)
            expect(groups_double).to receive(:find_by_slug!).with(group).and_return(group_double)
            expect(group_double).to receive(scope.to_sym).with(page).and_return(conversations_double)
            expect(controller).to receive(:serialize).with(:conversations, conversations_double).and_return({conversations: []})
            request!
            expect(response.status).to eq 200
          end

          context 'and the scope "muted_conversations"' do
            let(:scope){ 'muted_conversations' }
            it 'calls organization.muted_conversations' do
            end
          end
          context 'and the scope "not_muted_conversations"' do
            let(:scope){ 'not_muted_conversations' }
            it 'calls organization.not_muted_conversations' do
            end
          end
          context 'and the scope "done_tasks"' do
            let(:scope){ 'done_tasks' }
            it 'calls organization.done_tasks' do
            end
          end
          context 'and the scope "not_done_tasks"' do
            let(:scope){ 'not_done_tasks' }
            it 'calls organization.not_done_tasks' do
            end
          end
          context 'and the scope "done_doing_tasks"' do
            let(:scope){ 'done_doing_tasks' }
            it 'calls organization.done_doing_tasks' do
            end
          end
          context 'and the scope "not_done_doing_tasks"' do
            let(:scope){ 'not_done_doing_tasks' }
            it 'calls organization.not_done_doing_tasks' do
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

        let(:electronics) { raceteam.groups.find_by_email_address_tag('electronics') }
        it 'adds the conversation to groups' do
          xhr :post, :create, format: :json, organization_id: raceteam.slug, conversation: { subject: 'my conversation', group_ids: [electronics.id] }
          expect(response.status).to eq 201
          conversation = raceteam.conversations.find_by_slug('my-conversation')
          expect(conversation).to be
          expect(conversation.groups.all.map(&:email_address_tag)).to match_array ['electronics']
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
          expect(response.body).to eq '{"error":"param is missing or the value is empty: conversation"}'
        end
      end

      context 'with a blank subject' do
        it 'returns a param not found error' do
          xhr :post, :create, format: :json, organization_id: raceteam.slug, conversation: { subject: '' }
          expect(response.status).to eq 406
          expect(response.body).to eq '{"error":"param is missing or the value is empty: subject"}'
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

      context 'when given task' do
        it 'changes the conversation to / from a conversation / task' do
          expect( raceteam.conversations.find_by_slug('layup-body-carbon') ).to be_task

          xhr :put, :update, format: :json, organization_id: raceteam.slug, id: 'layup-body-carbon', conversation: { task: false }
          expect(response.status).to eq 200
          expect( raceteam.conversations.find_by_slug('layup-body-carbon') ).to_not be_task

          xhr :put, :update, format: :json, organization_id: raceteam.slug, id: 'layup-body-carbon', conversation: { task: true }
          expect(response.status).to eq 200
          expect( raceteam.conversations.find_by_slug('layup-body-carbon') ).to be_task
        end
      end

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

      context 'when given groups' do
        let(:electronics) { raceteam.groups.find_by_email_address_tag('electronics')}
        let(:fundraising)   { raceteam.groups.find_by_email_address_tag('fundraising')}
        let(:graphic_design)   { raceteam.groups.find_by_email_address_tag('graphic-design')}
        it 'sets the groups' do
          xhr :put, :update, format: :json, organization_id: raceteam.slug, id: 'get-a-new-soldering-iron', conversation: {
            group_ids: [electronics.id, fundraising.id, graphic_design.id]
          }
          expect(response.status).to eq 200
          conversation = raceteam.conversations.find_by_slug('get-a-new-soldering-iron')
          expect(conversation.groups.all.map(&:id)).to match_array [electronics.id, fundraising.id, graphic_design.id]
          expect(conversation.events.all.length).to eq(6)
        end
      end

      context 'when given empty groups' do
        it 'sets the groups' do
          xhr :put, :update, format: :json, organization_id: raceteam.slug, id: 'get-a-new-soldering-iron', conversation: {
            group_ids: nil
          }
          expect(response.status).to eq 200
          conversation = raceteam.conversations.find_by_slug('get-a-new-soldering-iron')
          expect(conversation.groups.all.length).to eq 1
          expect(conversation.groups.all.first.slug).to eq 'raceteam'
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

      context 'when given trashed/untrashed' do
        it 'trashes and untrashes the conversation' do
          xhr :put, :update, format: :json, organization_id: raceteam.slug, id: 'layup-body-carbon', conversation: {
            trashed: true
          }
          expect(response.status).to eq 200
          conversation = raceteam.conversations.find_by_slug('layup-body-carbon')
          expect(conversation.trashed?).to be_true
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
