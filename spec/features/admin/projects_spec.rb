require 'spec_helper'

feature "Admin projects CRUD" do

  # let :jared do
  #   covered.users.create!(
  #     name: 'Jared Grippe',
  #     email_address: 'jared@other.io',
  #     admin: true,
  #     password: 'password',
  #     password_confirmation: 'password',
  #   )
  # end

  let(:jared) { covered.users.find_by_email_address! 'jared@other.io'  }
  let(:ian)   { covered.users.find_by_email_address! 'ian@other.io'    }
  let(:nicole){ covered.users.find_by_email_address! 'nicole@other.io' }
  let(:aaron) { covered.users.find_by_email_address! 'aaron@other.io'  }

  def members_table
    all('.members.table tbody tr').map do |tr|
      tr.all('td').first(3).map(&:text)
    end
  end

  scenario %(creating a project) do
    sign_in_as 'jared@other.io'
    visit admin_new_project_path
    fill_in 'Name', with: 'United Nations'
    click_on 'Create Project'
    expect(page).to have_text 'Notice! Project was successfully created.'
    expect(page).to have_text 'Edit project'
    expect(current_url).to eq admin_edit_project_url('united-nations')

    within '.edit-project-form' do
      expect(page).to have_field "Name",                   with: "United Nations"
      expect(page).to have_field "Subject tag",            with: "United Nations"
      expect(page).to have_field "Slug",                   with: "united-nations"
      expect(page).to have_field "Email address username", with: "united.nations"
    end

    project = covered.projects.find_by_name!("United Nations")
    expect(project.name                  ).to eq "United Nations"
    expect(project.subject_tag           ).to eq "United Nations"
    expect(project.slug                  ).to eq "united-nations"
    expect(project.email_address_username).to eq "united.nations"

    within '.edit-project-form' do
      fill_in "Name",                   with: "United Hations"
      fill_in "Subject tag",            with: "United Hations"
      fill_in "Slug",                   with: "united-hations"
      fill_in "Email address username", with: "united.hations"
      click_on 'Update Project'
    end
    expect(page).to have_text 'Notice! Project was successfully updated.'
    project = covered.projects.find_by_name!("United Hations")
    expect(project.name                  ).to eq "United Hations"
    expect(project.subject_tag           ).to eq "United Hations"
    expect(project.slug                  ).to eq "united-hations"
    expect(project.email_address_username).to eq "united.hations"

    expect(project.members.all).to be_empty

    expect(members_table).to eq [["This project has no members."]]

    within '.add-existing-member-form' do
      select 'Nicole Aptekar <nicole@other.io>', from: 'user[id]'
      click_on 'Add Member'
    end

    expect(members_table).to eq [
      ["Nicole Aptekar", "nicole@other.io", "yes"],
    ]
    expect( project.members ).to include nicole

    within '.add-existing-member-form' do
      select 'Ian Baker <ian@other.io>', from: 'user[id]'
      uncheck 'Gets email?'
      uncheck 'Send join notice?'
      click_on 'Add Member'
    end

    expect(members_table).to match_array [
      ["Nicole Aptekar", "nicole@other.io", "yes"],
      ["Ian Baker",      "ian@other.io",    "no" ],
    ]
    expect( project.members ).to include ian

    assert_background_job_enqueued     SendEmailWorker, args: [covered.env, "join_notice", project.id, nicole.id, nil]
    assert_background_job_not_enqueued SendEmailWorker, args: [covered.env, "join_notice", project.id, ian.id,    nil]

    expect( project.members.find_by_user_id!(nicole.id).gets_email? ).to be_true
    expect( project.members.find_by_user_id!(ian.id   ).gets_email? ).to be_false

    within '.add-new-member-form' do
      fill_in 'Name', with: 'You Face'
      fill_in 'Email address', with: 'you@face.io'
      click_on 'Add Member'
    end

    expect(members_table).to match_array [
      ["Nicole Aptekar", "nicole@other.io", "yes"],
      ["Ian Baker",      "ian@other.io",    "no" ],
      ["You Face",       "you@face.io",     "yes"],
    ]
    you_face = project.members.find_by_user_slug!('you-face')
    expect( you_face.gets_email? ).to be_true
    assert_background_job_enqueued SendEmailWorker, args: [covered.env, "join_notice", project.id, you_face.id, nil]

    within '.add-new-member-form' do
      fill_in 'Name', with: 'Someone Else'
      fill_in 'Email address', with: 'someone@else.io'
      uncheck 'Gets email?'
      uncheck 'Send join notice?'
      click_on 'Add Member'
    end

    expect(members_table).to match_array [
      ["Nicole Aptekar", "nicole@other.io", "yes"],
      ["Ian Baker",      "ian@other.io",    "no" ],
      ["You Face",       "you@face.io",     "yes"],
      ["Someone Else",   "someone@else.io", "no" ],
    ]
    someone_else = project.members.find_by_user_slug!('someone-else')
    expect( someone_else.gets_email? ).to be_false
    assert_background_job_not_enqueued SendEmailWorker, args: [covered.env, "join_notice", project.id, someone_else.id, nil]

    within first('.members.table tbody tr') do
      click_on 'remove'
      accept_prompt!
    end

    expect(members_table).to match_array [
      ["Ian Baker",      "ian@other.io",    "no" ],
      ["You Face",       "you@face.io",     "yes"],
      ["Someone Else",   "someone@else.io", "no" ],
    ]

    expect( project.members ).to_not include nicole

  end

end
