class Test::JavascriptsController < TestController

  layout false

  SPECS_PATH = Rails.root.join('spec/javascripts')
  VIEWS = Rails.root.join("app/views")
  FIXTURES = VIEWS.join("test/javascripts/fixtures")

  def show
    @specs = Dir[SPECS_PATH + '**/*_spec.js'].map do |spec|
      Pathname(spec).relative_path_from(SPECS_PATH).to_s.sub(/_spec\.js$/,'')
    end

    sign_in! User.with_email_address('tom@ucsd.covered.io').first!

    @project = current_user.projects.find_by_slug! 'raceteam'
    @task = @project.tasks.latest
    @conversation = @project.conversations.find_by_slug! "layup-body-carbon"
    @message = @conversation.messages.find_by_id! @conversation.conversation_record.messages.where("body_plain != stripped_plain").last!.id

    @fixtures = {}
    Dir[FIXTURES.join("**/*")].each do |path|
      path = Pathname(path)
      next unless path.file?
      render_fixture(path)
    end
  end


  def render_fixture path
    render_path = path.relative_path_from(VIEWS).to_s.sub(/\.\w+\.\w+$/,'')
    name = path.relative_path_from(FIXTURES).sub(/_fixture\..+$/, '')
    ActiveRecord::Base.transaction do
      @fixtures[name] = view_context.render(file: render_path)
      raise ActiveRecord::Rollback
    end
  rescue ActiveRecord::Rollback
  end

end
