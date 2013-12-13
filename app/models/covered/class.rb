class Covered::Class

  EMAIL_HOSTS = {
    'beta.covered.io'        => 'covered.io',
    'www-staging.covered.io' => 'staging.covered.io'
  }.freeze

  include Let

  def initialize options={}
    options = options.symbolize_keys
    @host     = options.fetch(:host){ raise ArgumentError, 'required options: :host' }
    @port     = options.fetch(:port){ 80 }
    @protocol = options.fetch(:protocol){ 'http' }
    self.current_user_id = options[:current_user_id]
  end

  attr_reader :protocol, :host, :port, :current_user_id, :tracker

  def current_user_id= user_id
    @current_user_id = user_id
    @current_user = nil
    Honeybadger.context(user_id: @current_user_id)
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

  let(:emails         ){ Covered::Emails         .new(self) }
  let(:email_addresses){ Covered::EmailAddresses .new(self) }
  let(:users          ){ Covered::Users          .new(self) }
  let(:projects       ){ Covered::Projects       .new(self) }
  let(:conversations  ){ Covered::Conversations  .new(self) }
  let(:tasks          ){ Covered::Tasks          .new(self) }
  let(:messages       ){ Covered::Messages       .new(self) }
  let(:attachments    ){ Covered::Attachments    .new(self) }
  let(:incoming_emails){ Covered::IncomingEmails .new(self) }
  let(:events         ){ Covered::Events         .new(self) }

  def sign_up attributes
    Covered::SignUp.call(self, attributes)
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

  def report_exception! exception
    logger.error("\n\nEXCEPTION: #{exception.class}(#{exception.message.inspect})\n#{exception.backtrace.join("\n")}\n\n")
    Honeybadger.notify(exception)
    track("Exception",
      'Class'     => exception.class,
      'Message'   => exception.message,
      'Backtrace' => exception.backtrace.first,
    )
  end

  def == other
    self.class === other && self.env == other.env
  end

  def inspect
    %(#<#{self.class} #{env.inspect}>)
  end

end
