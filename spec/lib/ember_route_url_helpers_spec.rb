require 'spec_helper'

describe EmberRouteUrlHelpers, fixtures: false do

  let :helper do
    helper_class = Class.new do
      include Rails.application.routes.url_helpers
    end
    helper_class.default_url_options = default_url_options
    helper_class.new
  end

  def default_url_options
    {
      host: 'example.com',
      port: 3456,
    }
  end

  it "returns the expected urls" do
    expect(helper.root_url).to eq "http://example.com:3456/"

    expect( helper.organization_member_url        'raceteam', '1'                                ).to eq 'http://example.com:3456/raceteam/members/1'
    expect( helper.organization_members_url       'raceteam'                                     ).to eq 'http://example.com:3456/raceteam/members'
    expect( helper.add_organization_member_url    'raceteam'                                     ).to eq 'http://example.com:3456/raceteam/members/add'
    expect( helper.group_member_url               'raceteam', 'electronics', '1'                 ).to eq 'http://example.com:3456/raceteam/electronics/members/1'
    expect( helper.group_members_url              'raceteam', 'electronics'                      ).to eq 'http://example.com:3456/raceteam/electronics/members'
    expect( helper.conversation_url               'raceteam', 'electronics', 'who-ate-my-cheese' ).to eq 'http://example.com:3456/raceteam/electronics/conversations/who-ate-my-cheese'
    expect( helper.compose_conversation_url       'raceteam', 'electronics'                      ).to eq 'http://example.com:3456/raceteam/electronics/conversations/compose'
    expect( helper.conversations_url              'raceteam', 'electronics'                      ).to eq 'http://example.com:3456/raceteam/electronics/conversations'
    expect( helper.muted_conversation_url         'raceteam', 'electronics', 'who-ate-my-cheese' ).to eq 'http://example.com:3456/raceteam/electronics/muted-conversations/who-ate-my-cheese'
    expect( helper.compose_muted_conversation_url 'raceteam', 'electronics'                      ).to eq 'http://example.com:3456/raceteam/electronics/muted-conversations/compose'
    expect( helper.muted_conversations_url        'raceteam', 'electronics'                      ).to eq 'http://example.com:3456/raceteam/electronics/muted-conversations'
    expect( helper.task_url                       'raceteam', 'electronics', 'who-ate-my-cheese' ).to eq 'http://example.com:3456/raceteam/electronics/tasks/who-ate-my-cheese'
    expect( helper.compose_task_url               'raceteam', 'electronics'                      ).to eq 'http://example.com:3456/raceteam/electronics/tasks/compose'
    expect( helper.tasks_url                      'raceteam', 'electronics'                      ).to eq 'http://example.com:3456/raceteam/electronics/tasks'
    expect( helper.doing_task_url                 'raceteam', 'electronics', 'who-ate-my-cheese' ).to eq 'http://example.com:3456/raceteam/electronics/doing-tasks/who-ate-my-cheese'
    expect( helper.compose_doing_task_url         'raceteam', 'electronics'                      ).to eq 'http://example.com:3456/raceteam/electronics/doing-tasks/compose'
    expect( helper.doing_tasks_url                'raceteam', 'electronics'                      ).to eq 'http://example.com:3456/raceteam/electronics/doing-tasks'
    expect( helper.group_url                      'raceteam', 'electronics'                      ).to eq 'http://example.com:3456/raceteam/electronics'
    expect( helper.organization_url               'raceteam'                                     ).to eq 'http://example.com:3456/raceteam'
  end

  it 'url encodes values before generating a path' do
    expect( helper.conversation_url 'raceteam', 'electronics', 'cats->-than-dogs' ).to eq 'http://example.com:3456/raceteam/electronics/conversations/cats-%3E-than-dogs'
  end

end
