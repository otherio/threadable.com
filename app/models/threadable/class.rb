class Threadable::Class

  EMAIL_HOSTS = {
    'beta.threadable.io'        => 'threadable.io',
    'www-staging.threadable.io' => 'staging.threadable.io',
    '127.0.0.1'              => '127.0.0.1', # for dev
  }.freeze

  include Let

  def initialize options={}
    options = options.symbolize_keys
    @host     = options.fetch(:host){ raise ArgumentError, 'required options: :host' }
    @port     = options.fetch(:port){ 80 }
    @protocol = options.fetch(:protocol){ 'http' }
    @worker   = options.fetch(:worker)  { false }
    self.current_user_id = options[:current_user_id]
  end

  attr_reader :protocol, :host, :port, :current_user_id, :tracker, :worker

  def current_user_id= user_id
    @current_user_id = user_id
    @current_user = nil
    Honeybadger.context(user_id: @current_user_id)
  end

  def current_user= user
    self.current_user_id = user.try(:user_id)
  end

  def current_user
    return nil if @current_user_id.nil?
    @current_user ||= Threadable::CurrentUser.new(self, @current_user_id)
  end


  let :tracker do
    Rails.application.config.track_in_memory ?
      Threadable::InMemoryTracker.new(self) :
      Threadable::MixpanelTracker.new(self)
  end
  delegate :track, to: :tracker

  let(:emails         ){ Threadable::Emails         .new(self) }
  let(:email_addresses){ Threadable::EmailAddresses .new(self) }
  let(:users          ){ Threadable::Users          .new(self) }
  let(:organizations  ){ Threadable::Organizations  .new(self) }
  let(:conversations  ){ Threadable::Conversations  .new(self) }
  let(:tasks          ){ Threadable::Tasks          .new(self) }
  let(:messages       ){ Threadable::Messages       .new(self) }
  let(:attachments    ){ Threadable::Attachments    .new(self) }
  let(:incoming_emails){ Threadable::IncomingEmails .new(self) }
  let(:events         ){ Threadable::Events         .new(self) }
  let(:groups         ){ Threadable::Groups         .new(self) }

  def sign_up attributes
    Threadable::SignUp.call(self, attributes)
  end

  def email_host
    Threadable::Class::EMAIL_HOSTS[host] || host
  end

  def support_email_address tag=nil
    tag.nil? ? "support@#{email_host}" : "support+#{tag}@#{email_host}"
  end

  def env
    {
      protocol:        protocol,
      host:            host,
      port:            port,
      current_user_id: current_user_id,
      worker:          worker,
    }.as_json
  end

  def report_exception! exception
    Rails.logger.error("\n\nEXCEPTION: #{exception.class}(#{exception.message.inspect})\n#{exception.backtrace.join("\n")}\n\n")
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
  alias_method :eql?, :==

  def inspect
    %(#<#{self.class} #{env.inspect}>)
  end

end
