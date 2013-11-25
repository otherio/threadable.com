class Covered::Class

  def initialize options={}
    options = options.symbolize_keys
    @host            = options.fetch(:host){ raise ArgumentError, 'required options: :host' }
    @port            = options.fetch(:port){ 80 }
    @protocol        = options.fetch(:protocol){ 'http' }
    @current_user_id = options[:current_user_id]
  end

  attr_reader :protocol, :host, :port, :current_user_id

  def current_user_id= user_id
    @current_user_id = user_id
    @current_user = nil
  end

  def current_user
    return nil if @current_user_id.nil?
    @current_user ||= Covered::CurrentUser.new(self, @current_user_id)
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

  def users
    @users ||= Covered::Users.new(self)
  end

  def sign_up attributes
    Covered::SignUp.call(attributes.merge(covered: self))
  end

  def emails
    @emails ||= Covered::Emails.new(self)
  end

  def enqueue background_job_name, *args
    background_jobs.respond_to?(background_job_name) or raise ArgumentError, "invalid background job: #{background_job_name}"
    Covered::Worker.enqueue_async(covered.env, background_job_name, *args)
  end

  def process_incoming_email incoming_email
    Covered::ProcessIncomingEmail.call(self, incoming_email)
  end

  def inspect
    %(#<#{self.class} #{env.inspect}>)
  end

end

require 'covered/worker'
require 'covered/users'
require 'covered/current_user'
require 'covered/emails'
require 'covered/sign_up'
