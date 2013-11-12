module RequestExampleGroup

  extend ActiveSupport::Concern

  included do
    let(:current_user){ nil }
    let(:covered){ Covered.new(host: host, port: port, current_user: current_user, protocol: protocol) }
    let(:host){ URI.parse(root_url).host }
    let(:port){ URI.parse(root_url).port }
    let(:protocol) { 'http' }
  end

  def sign_in_as user, remember_me: false
    post sign_in_path, {
      "authentication" => {
        "email"       => user.email,
        "password"    => "password",
        "remember_me" => remember_me ? 0 : 1
      },
    }
    expect(response).to be_success
    covered.env["current_user_id"] = user.id if defined?(covered)
  end

  def sign_out!
    visit sign_out_path
    visit root_path
    page.should have_content('Sign in')
  end

end

RSpec::configure do |c|
  c.include RequestExampleGroup, :type => :request
end
