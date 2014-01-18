require 'spec_helper'

describe "/api/conversations" do


  when_signed_in_as 'bethany@ucsd.example.com' do
    describe "GET" do
      def request! context, scope, group_id=nil
        get('/api/conversations.json',
          organization_id: 'raceteam',
          context:         context,
          scope:           scope,
          group_id:        group_id,
        )
        expect(response.status).to eq 200
        JSON.parse(response.body)["conversations"]
      end

      def check_consistancy!
        expect(@muted_conversations & @not_muted_conversations).to eq []
        expect(@all_tasks & @doing_tasks).to eq @doing_tasks

            @muted_conversations.each{|conversation| expect(conversation['muted']).to be_true }
        @not_muted_conversations.each{|conversation| expect(conversation['muted']).to be_false }

        @doing_tasks.each{|task|
          expect(task['doers'].map{|d| d['id']}).to include current_user.id
        }
      end

      let(:raceteam){ current_user.organizations.find_by_slug!('raceteam') }

      def my_group_ids
        @my_group_ids ||= raceteam.groups.my.map(&:id)
      end

      context 'when given bad params' do
        it "renders either not authorized or not found" do
          get('/api/conversations.json')
          expect(response.status).to eq 406
          expect(response.body).to include 'param not found: organization_id'

          get('/api/conversations.json', organization_id: 'raceteam')
          expect(response.status).to eq 406
          expect(response.body).to include 'param not found: context'

          get('/api/conversations.json', organization_id: 'raceteam', context: 'my')
          expect(response.status).to eq 406
          expect(response.body).to include 'param not found: scope'

          get('/api/conversations.json', organization_id: 'raceteam', context: 'my', scope: 'muted_conversations')
          expect(response.status).to eq 200

          get('/api/conversations.json', organization_id: 'raceteam', context: 'group', scope: 'muted_conversations')
          expect(response.status).to eq 406
          expect(response.body).to include 'param not found: group_id'

          get('/api/conversations.json', organization_id: 'raceteam', context: 'group', scope: 'muted_conversations', group_id: 'electronics')
          expect(response.status).to eq 200

          get('/api/conversations.json', organization_id: '12121', context: 'my', scope: 'muted_conversations')
          expect(response.status).to eq 404

          get('/api/conversations.json', organization_id: 'raceteam', context: 'group', scope: 'muted_conversations', group_id: 'foobar')
          expect(response.status).to eq 404
        end
      end


      it 'renders the expected conversations' do

        # conversations and tasks for the current user

            @muted_conversations = request! 'my', 'muted_conversations'
        @not_muted_conversations = request! 'my', 'not_muted_conversations'
                      @all_tasks = request! 'my', 'all_task'
                    @doing_tasks = request! 'my', 'doing_tasks'

        check_consistancy!

        (@muted_conversations + @not_muted_conversations + @all_tasks + @doing_tasks).each do |conversation|
          conversation['group_ids'].empty? || (conversation['group_ids'] & my_group_ids).present? or fail("#{conversation['slug'].inspect} is not mine.")
        end

        expect(@muted_conversations.map{|c| c["slug"] }).to eq [
          "layup-body-carbon",
          "get-carbon-and-fiberglass",
          "get-release-agent",
          "get-epoxy",
          "parts-for-the-drive-train",
          "welcome-to-our-covered-organization"
        ]

        expect(@not_muted_conversations.map{|c| c["slug"] }).to eq [
          "who-wants-to-pick-up-breakfast",
          "who-wants-to-pick-up-dinner",
          "who-wants-to-pick-up-lunch",
          "get-some-4-gauge-wire",
          "get-a-new-soldering-iron",
          "make-wooden-form-for-carbon-layup",
          "trim-body-panels",
          "install-mirrors",
          "parts-for-the-motor-controller",
          "how-are-we-going-to-build-the-body"
        ]

        expect(@all_tasks.map{|c| c["slug"] }).to eq [
          "layup-body-carbon",
          "install-mirrors",
          "trim-body-panels",
          "make-wooden-form-for-carbon-layup",
          "get-epoxy",
          "get-release-agent",
          "get-carbon-and-fiberglass",
          "get-a-new-soldering-iron",
          "get-some-4-gauge-wire"
        ]

        expect(@doing_tasks.map{|c| c["slug"] }).to eq [
          "get-a-new-soldering-iron",
        ]


        # conversations and tasks not in any group

            @muted_conversations = request! 'ungrouped', 'muted_conversations'
        @not_muted_conversations = request! 'ungrouped', 'not_muted_conversations'
                      @all_tasks = request! 'ungrouped', 'all_task'
                    @doing_tasks = request! 'ungrouped', 'doing_tasks'

        check_consistancy!


        (@muted_conversations + @not_muted_conversations + @all_tasks + @doing_tasks).each do |conversation|
          expect(conversation['group_ids']).to be_empty
        end


        expect(@muted_conversations.map{|c| c["slug"] }).to eq [
          "layup-body-carbon",
          "get-carbon-and-fiberglass",
          "get-release-agent",
          "get-epoxy",
          "welcome-to-our-covered-organization",
        ]

        expect(@not_muted_conversations.map{|c| c["slug"] }).to eq [
          "who-wants-to-pick-up-breakfast",
          "who-wants-to-pick-up-dinner",
          "who-wants-to-pick-up-lunch",
          "make-wooden-form-for-carbon-layup",
          "trim-body-panels",
          "install-mirrors",
          "how-are-we-going-to-build-the-body",
        ]

        expect(@all_tasks.map{|c| c["slug"] }).to eq [
          "layup-body-carbon",
          "install-mirrors",
          "trim-body-panels",
          "make-wooden-form-for-carbon-layup",
          "get-epoxy",
          "get-release-agent",
          "get-carbon-and-fiberglass",
        ]

        expect(@doing_tasks.map{|c| c["slug"] }).to eq [

        ]


        # conversations and tasks for the electronics group

        electronics = raceteam.groups.find_by_email_address_tag('electronics')

            @muted_conversations = request! 'group', 'muted_conversations',     'electronics'
        @not_muted_conversations = request! 'group', 'not_muted_conversations', 'electronics'
                      @all_tasks = request! 'group', 'all_task',                'electronics'
                    @doing_tasks = request! 'group', 'doing_tasks',             'electronics'

        check_consistancy!

        (@muted_conversations + @not_muted_conversations + @all_tasks + @doing_tasks).each do |conversation|
          expect(conversation['group_ids']).to include electronics.group_id
        end

        expect(@muted_conversations.map{|c| c["slug"] }).to eq [
          "parts-for-the-drive-train",
        ]

        expect(@not_muted_conversations.map{|c| c["slug"] }).to eq [
          "get-some-4-gauge-wire",
          "get-a-new-soldering-iron",
          "parts-for-the-motor-controller",
        ]

        expect(@all_tasks.map{|c| c["slug"] }).to eq [
          "get-a-new-soldering-iron",
          "get-some-4-gauge-wire"
        ]

        expect(@doing_tasks.map{|c| c["slug"] }).to eq [
          "get-a-new-soldering-iron"
        ]

        # conversations and tasks for the fundraising group

        fundraising = raceteam.groups.find_by_email_address_tag('fundraising')

            @muted_conversations = request! 'group', 'muted_conversations',     'fundraising'
        @not_muted_conversations = request! 'group', 'not_muted_conversations', 'fundraising'
                      @all_tasks = request! 'group', 'all_task',                'fundraising'
                    @doing_tasks = request! 'group', 'doing_tasks',             'fundraising'

        check_consistancy!

        (@muted_conversations + @not_muted_conversations + @all_tasks + @doing_tasks).each do |conversation|
          expect(conversation['group_ids']).to include fundraising.group_id
        end

        expect(@muted_conversations.map{|c| c["slug"] }).to eq [

        ]

        expect(@not_muted_conversations.map{|c| c["slug"] }).to eq [
          "how-are-we-paying-for-the-motor-controller"
        ]

        expect(@all_tasks.map{|c| c["slug"] }).to eq [

        ]

        expect(@doing_tasks.map{|c| c["slug"] }).to eq [

        ]
      end
    end
  end

end
