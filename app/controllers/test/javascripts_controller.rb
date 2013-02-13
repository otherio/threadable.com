class Test::JavascriptsController < TestController

  layout false

  SPECS_PATH = Rails.root.join('spec/javascripts')

  def show
    @specs = Dir[SPECS_PATH + '**/*_spec.js'].map do |spec|
      Pathname(spec).relative_path_from(SPECS_PATH).to_s.sub(/_spec\.js$/,'')
    end

    @fixtures = {}
    @specs.each do |spec|
      ActiveRecord::Base.transaction do
        @fixtures[spec] = view_context.render(file: "/test/javascripts/fixtures/#{spec}_fixture")
      end
    end
  rescue Object => e
    render text: "ERROR: #{e}\n#{e.backtrace*"\n"}", status: 500
  end

end
