require 'spec_helper'

describe 'getting conversations' do


  # org.conversations.not_muted
  # org.conversations.muted
  # org.tasks.all
  # org.tasks.doing

  # org.conversations.my.not_muted
  # org.conversations.my.muted
  # org.tasks.my.all
  # org.tasks.my.doing

  # org.conversations.ungrouped.not_muted
  # org.conversations.ungrouped.muted
  # org.tasks.ungrouped.all
  # org.tasks.ungrouped.doing

  # group.conversations.my.not_muted
  # group.conversations.my.muted
  # group.tasks.my.all
  # group.tasks.my.doing

  when_signed_in_as 'bethany@ucsd.example.com' do
    def check_consistancy!
      expect(@muted_conversations & @not_muted_conversations).to eq []
      expect(@all_conversations - @muted_conversations).to eq @not_muted_conversations
      expect(@all_conversations - @not_muted_conversations).to eq @muted_conversations
      expect(@all_tasks & @doing_tasks).to eq @doing_tasks

          @muted_conversations.each{|conversation| expect(conversation).to     be_muted }
      @not_muted_conversations.each{|conversation| expect(conversation).to_not be_muted }

      @doing_tasks.each{|task| expect(task.doers).to include current_user }
    end

    it 'can get conversations' do
      raceteam = current_user.organizations.find_by_slug!('raceteam')

            @all_conversations = nil
          @muted_conversations = nil
      @not_muted_conversations = nil
                    @all_tasks = nil
                  @doing_tasks = nil



      # conversations and tasks for the whole organization

            @all_conversations = raceteam.conversations.all
          @muted_conversations = raceteam.conversations.muted
      @not_muted_conversations = raceteam.conversations.not_muted
                    @all_tasks = raceteam.tasks.all
                  @doing_tasks = raceteam.tasks.doing

      check_consistancy!

      expect(@all_conversations.map(&:slug)).to eq [
        "who-wants-to-pick-up-breakfast",
        "who-wants-to-pick-up-dinner",
        "who-wants-to-pick-up-lunch",
        "layup-body-carbon",
        "get-carbon-and-fiberglass",
        "get-release-agent",
        "get-epoxy",
        "get-some-4-gauge-wire",
        "get-a-new-soldering-iron",
        "make-wooden-form-for-carbon-layup",
        "trim-body-panels",
        "install-mirrors",
        "how-are-we-paying-for-the-motor-controller",
        "parts-for-the-drive-train",
        "parts-for-the-motor-controller",
        "how-are-we-going-to-build-the-body",
        "welcome-to-our-covered-organization",
      ]

      expect(@muted_conversations.map(&:slug)).to eq [
        "layup-body-carbon",
        "get-carbon-and-fiberglass",
        "get-release-agent",
        "get-epoxy",
        "parts-for-the-drive-train",
        "welcome-to-our-covered-organization",
      ]

      expect(@not_muted_conversations.map(&:slug)).to eq [
        "who-wants-to-pick-up-breakfast",
        "who-wants-to-pick-up-dinner",
        "who-wants-to-pick-up-lunch",
        "get-some-4-gauge-wire",
        "get-a-new-soldering-iron",
        "make-wooden-form-for-carbon-layup",
        "trim-body-panels",
        "install-mirrors",
        "how-are-we-paying-for-the-motor-controller",
        "parts-for-the-motor-controller",
        "how-are-we-going-to-build-the-body",
      ]

      expect(@all_tasks.map(&:slug)).to eq [
        "layup-body-carbon",
        "install-mirrors",
        "trim-body-panels",
        "make-wooden-form-for-carbon-layup",
        "get-epoxy",
        "get-release-agent",
        "get-carbon-and-fiberglass",
        "get-a-new-soldering-iron",
        "get-some-4-gauge-wire",
      ]

      expect(@doing_tasks.map(&:slug)).to eq [
        "get-a-new-soldering-iron",
      ]


      # conversations and tasks for the electronics group

      electronics = raceteam.groups.find_by_email_address_tag('electronics')

            @all_conversations = electronics.conversations.all
          @muted_conversations = electronics.conversations.muted
      @not_muted_conversations = electronics.conversations.not_muted
                    @all_tasks = electronics.tasks.all
                  @doing_tasks = electronics.tasks.doing

      check_consistancy!

      (@all_conversations + @muted_conversations + @not_muted_conversations + @all_tasks + @doing_tasks).each do |conversation|
        expect(conversation.groups).to include electronics
      end

      expect(@all_conversations.map(&:slug)).to eq [
        "get-some-4-gauge-wire",
        "get-a-new-soldering-iron",
        "parts-for-the-drive-train",
        "parts-for-the-motor-controller",
      ]

      expect(@muted_conversations.map(&:slug)).to eq [
        "parts-for-the-drive-train",
      ]

      expect(@not_muted_conversations.map(&:slug)).to eq [
        "get-some-4-gauge-wire",
        "get-a-new-soldering-iron",
        "parts-for-the-motor-controller",
      ]

      expect(@all_tasks.map(&:slug)).to eq [
        "get-a-new-soldering-iron",
        "get-some-4-gauge-wire"
      ]

      expect(@doing_tasks.map(&:slug)).to eq [
        "get-a-new-soldering-iron"
      ]


      # conversations and tasks for the fundraising group

      fundraising = raceteam.groups.find_by_email_address_tag('fundraising')

            @all_conversations = fundraising.conversations.all
          @muted_conversations = fundraising.conversations.muted
      @not_muted_conversations = fundraising.conversations.not_muted
                    @all_tasks = fundraising.tasks.all
                  @doing_tasks = fundraising.tasks.doing

      check_consistancy!

      (@all_conversations + @muted_conversations + @not_muted_conversations + @all_tasks + @doing_tasks).each do |conversation|
        expect(conversation.groups).to include fundraising
      end


      expect(@all_conversations.map(&:slug)).to eq [
        "how-are-we-paying-for-the-motor-controller"
      ]

      expect(@muted_conversations.map(&:slug)).to eq [

      ]

      expect(@not_muted_conversations.map(&:slug)).to eq [
        "how-are-we-paying-for-the-motor-controller"
      ]

      expect(@all_tasks.map(&:slug)).to eq [

      ]

      expect(@doing_tasks.map(&:slug)).to eq [

      ]

      # conversations and tasks for the current user

            @all_conversations = raceteam.conversations.my.all
          @muted_conversations = raceteam.conversations.my.muted
      @not_muted_conversations = raceteam.conversations.my.not_muted
                    @all_tasks = raceteam.tasks.my.all
                  @doing_tasks = raceteam.tasks.my.doing

      check_consistancy!

      (@all_conversations + @muted_conversations + @not_muted_conversations + @all_tasks + @doing_tasks).each do |conversation|
        conversation.groups.empty? || (conversation.groups.all & raceteam.groups.my).present? or fail("#{conversation.inspect} is not mine.")
      end

      expect(@all_conversations.map(&:slug)).to eq [
        "who-wants-to-pick-up-breakfast",
        "who-wants-to-pick-up-dinner",
        "who-wants-to-pick-up-lunch",
        "layup-body-carbon",
        "get-carbon-and-fiberglass",
        "get-release-agent",
        "get-epoxy",
        "get-some-4-gauge-wire",
        "get-a-new-soldering-iron",
        "make-wooden-form-for-carbon-layup",
        "trim-body-panels",
        "install-mirrors",
        "parts-for-the-drive-train",
        "parts-for-the-motor-controller",
        "how-are-we-going-to-build-the-body",
        "welcome-to-our-covered-organization"
      ]

      expect(@muted_conversations.map(&:slug)).to eq [
        "layup-body-carbon",
        "get-carbon-and-fiberglass",
        "get-release-agent",
        "get-epoxy",
        "parts-for-the-drive-train",
        "welcome-to-our-covered-organization"
      ]

      expect(@not_muted_conversations.map(&:slug)).to eq [
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

      expect(@all_tasks.map(&:slug)).to eq [
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

      expect(@doing_tasks.map(&:slug)).to eq [
        "get-a-new-soldering-iron",
      ]


      # conversations and tasks not in any group

            @all_conversations = raceteam.conversations.ungrouped.all
          @muted_conversations = raceteam.conversations.ungrouped.muted
      @not_muted_conversations = raceteam.conversations.ungrouped.not_muted
                    @all_tasks = raceteam.tasks.ungrouped.all
                  @doing_tasks = raceteam.tasks.ungrouped.doing

      check_consistancy!

      (@all_conversations + @muted_conversations + @not_muted_conversations + @all_tasks + @doing_tasks).each do |conversation|
        expect(conversation.groups).to be_empty
      end

      expect(@all_conversations.map(&:slug)).to eq [
        "who-wants-to-pick-up-breakfast",
        "who-wants-to-pick-up-dinner",
        "who-wants-to-pick-up-lunch",
        "layup-body-carbon",
        "get-carbon-and-fiberglass",
        "get-release-agent",
        "get-epoxy",
        "make-wooden-form-for-carbon-layup",
        "trim-body-panels",
        "install-mirrors",
        "how-are-we-going-to-build-the-body",
        "welcome-to-our-covered-organization",
      ]

      expect(@muted_conversations.map(&:slug)).to eq [
        "layup-body-carbon",
        "get-carbon-and-fiberglass",
        "get-release-agent",
        "get-epoxy",
        "welcome-to-our-covered-organization",
      ]

      expect(@not_muted_conversations.map(&:slug)).to eq [
        "who-wants-to-pick-up-breakfast",
        "who-wants-to-pick-up-dinner",
        "who-wants-to-pick-up-lunch",
        "make-wooden-form-for-carbon-layup",
        "trim-body-panels",
        "install-mirrors",
        "how-are-we-going-to-build-the-body",
      ]

      expect(@all_tasks.map(&:slug)).to eq [
        "layup-body-carbon",
        "install-mirrors",
        "trim-body-panels",
        "make-wooden-form-for-carbon-layup",
        "get-epoxy",
        "get-release-agent",
        "get-carbon-and-fiberglass",
      ]

      expect(@doing_tasks.map(&:slug)).to eq [

      ]

    end
  end

end
