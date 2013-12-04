class Covered::Class

  EMAIL_HOSTS = {
    'beta.covered.io' => 'covered.io',
    'www-staging.covered.io' => 'staging.covered.io'
  }.freeze

  include Let

  def initialize options={}
    options = options.symbolize_keys
    @host            = options.fetch(:host){ raise ArgumentError, 'required options: :host' }
    @port            = options.fetch(:port){ 80 }
    @protocol        = options.fetch(:protocol){ 'http' }
    @current_user_id = options[:current_user_id]
  end

  attr_reader :protocol, :host, :port, :current_user_id, :tracker

  def current_user_id= user_id
    @current_user_id = user_id
    @current_user = nil
  end

  def current_user= user
    self.current_user_id = user.id
  end

  def current_user
    return nil if @current_user_id.nil?
    @current_user ||= Covered::CurrentUser.new(self, @current_user_id)
  end


  let :tracker do
    Rails.application.config.track_in_memory ?
      Covered::InMemoryTracker.new(self) :
      Covered::MixpanelTracker.new(self)
  end
  delegate :track, to: :tracker

  let(:emails         ){ Covered::Emails.new(self)         }

  let(:users          ){ Covered::Users.new(self)          }
  let(:projects       ){ Covered::Projects.new(self)       }

  def sign_up attributes
    Covered::SignUp.call(attributes.merge(covered: self))
  end

  def process_incoming_email incoming_email
    Covered::ProcessIncomingEmail.call(self, incoming_email)
  end

  def email_host
    Covered::Class::EMAIL_HOSTS[host] || host
  end

  def env
    {
      protocol:        protocol,
      host:            host,
      port:            port,
      current_user_id: current_user_id,
    }.as_json
  end

  def == other
    self.class === other && self.env == other.env
  end

  def inspect
    %(#<#{self.class} #{env.inspect}>)
  end

end
