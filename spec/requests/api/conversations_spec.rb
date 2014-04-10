require 'spec_helper'

describe "/api/conversations" do


  when_signed_in_as 'bethany@ucsd.example.com' do
    describe "GET" do

      let(:organization){ current_user.organizations.find_by_slug!('raceteam') }

      context 'when given bad params' do
        it "renders either not authorized or not found" do
          get('/api/conversations.json')
          expect(response.status).to eq 406
          expect(response.body).to include 'param not found: organization'

          get('/api/conversations.json', organization: 'raceteam')
          expect(response.status).to eq 406
          expect(response.body).to include 'param not found: group'

          get('/api/conversations.json', organization: 'raceteam', group: 'my')
          expect(response.status).to eq 406
          expect(response.body).to include 'param not found: scope'

          get('/api/conversations.json', organization: 'raceteam', group: 'my', scope: 'muted_conversations')
          expect(response.status).to eq 406
          expect(response.body).to include 'param not found: page'

          get('/api/conversations.json', organization: 'raceteam', group: 'my', scope: 'muted_conversations', page: 0)
          expect(response.status).to eq 200

          get('/api/conversations.json', organization: 'raceteam', group: 'my', scope: 'asdsadsa', page: 0)
          expect(response.status).to eq 406

          get('/api/conversations.json', organization: '12121', group: 'my', scope: 'muted_conversations', page: 0)
          expect(response.status).to eq 404

          get('/api/conversations.json', organization: 'raceteam', group: 'foobar', scope: 'muted_conversations', page: 0)
          expect(response.status).to eq 404
        end
      end


      it 'renders the expected conversations' do
            @muted_conversations = request! 'my', 'muted_conversations'
        @not_muted_conversations = request! 'my', 'not_muted_conversations'
            @done_tasks          = request! 'my', 'done_tasks'
        @not_done_tasks          = request! 'my', 'not_done_tasks'
            @done_doing_tasks    = request! 'my', 'done_doing_tasks'
        @not_done_doing_tasks    = request! 'my', 'not_done_doing_tasks'

        check_consistency!

        all.each do |conversation|
          conversation['group_ids'].empty? || (conversation['group_ids'] & my_group_ids).present? or fail("#{conversation['slug'].inspect} is not mine.")
        end

            @muted_conversations = request! 'ungrouped', 'muted_conversations'
        @not_muted_conversations = request! 'ungrouped', 'not_muted_conversations'
            @done_tasks          = request! 'ungrouped', 'done_tasks'
        @not_done_tasks          = request! 'ungrouped', 'not_done_tasks'
            @done_doing_tasks    = request! 'ungrouped', 'done_doing_tasks'
        @not_done_doing_tasks    = request! 'ungrouped', 'not_done_doing_tasks'


        check_consistency!

        all.each do |conversation|
          expect(conversation['group_ids']).to be_empty
        end

        organization.groups.all.each do |group|

              @muted_conversations = request! group.slug, 'muted_conversations'
          @not_muted_conversations = request! group.slug, 'not_muted_conversations'
              @done_tasks          = request! group.slug, 'done_tasks'
          @not_done_tasks          = request! group.slug, 'not_done_tasks'
              @done_doing_tasks    = request! group.slug, 'done_doing_tasks'
          @not_done_doing_tasks    = request! group.slug, 'not_done_doing_tasks'

          check_consistency!

          all.each do |conversation|
            expect(conversation['group_ids']).to include group.group_id
          end

        end

      end

      def request! group, scope
        get('/api/conversations.json',
          organization: 'raceteam',
          group:        group,
          scope:        scope,
          page:         0,
        )
        expect(response.status).to eq 200
        JSON.parse(response.body)["conversations"]
      end

      def my_group_ids
        @my_group_ids ||= organization.groups.my.map(&:id)
      end

      def check_consistency!
        expect(@muted_conversations  & @not_muted_conversations).to eq []
        expect(@done_tasks           & @not_done_tasks         ).to eq []
        expect(@done_doing_tasks     & @not_done_doing_tasks   ).to eq []

            @muted_conversations.each{|conversation| expect(conversation['muted']).to be_true  }
        @not_muted_conversations.each{|conversation| expect(conversation['muted']).to be_false }


            @done_tasks      .each{|task| expect(task['done']).to be_true  }
        @not_done_tasks      .each{|task| expect(task['done']).to be_false }
            @done_doing_tasks.each{|task| expect(task['done']).to be_true  }
        @not_done_doing_tasks.each{|task| expect(task['done']).to be_false }

            @done_doing_tasks.each{|task| expect(task['doing']).to be_true }
        @not_done_doing_tasks.each{|task| expect(task['doing']).to be_true }
      end

      def all
            @muted_conversations +
        @not_muted_conversations +
            @done_tasks          +
        @not_done_tasks          +
            @done_doing_tasks    +
        @not_done_doing_tasks
      end

    end
  end

end
