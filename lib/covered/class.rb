require 'wtf'
require 'active_record_read_only'

class Covered::Class

  require 'covered/dependant'
  extend Covered::Dependant::ClassMethods

  dependant :operations, :background_jobs, :users, :projects, :conversations, :messages

  def initialize env={}
    @env = env.with_indifferent_access.delete_if{|k,v| v.nil?}
    @env[:host].present? or raise ArgumentError, 'host is required'
    @env[:port].present? or raise ArgumentError, 'port is required'
    if @current_user = @env.delete(:current_user)
      @env[:current_user_id] = @current_user.id
    end
    # @env[:current_user_id].present? or raise ArgumentError, 'current_user or current_user_id is required'
  end

  attr_reader :env

  %w{current_user_id host port}.each do |key|
    define_method(key){ @env[key] }
  end

  def current_user
    return nil unless current_user_id.present?
    @current_user = nil if @current_user && @current_user.id != current_user_id
    @current_user ||= Covered::User.find(current_user_id)
  rescue ActiveRecord::RecordNotFound
    raise Covered::CurrentUserNotFound, "id => #{current_user_id}"
  end

  def == other
    self.class === other && self.env == other.env
  end

  def background operation_name, options={}
    background_jobs.enqueue(operation_name, options)
  end

  def method_missing method, *args, &block
    return operations.public_send(method, *args) if operations.respond_to? method
    super
  end

  def respond_to? method, include_all=false
    operations.respond_to?(method, include_all) or super
  end

  def inspect
    %(#<#{self.class} #{env.inspect}>)
  end

  def signed_in?
    current_user.present?
  end

  def signed_in!
    signed_in? or raise Covered::AuthorizationError
  end

  # covered.send_email(:conversation_message, message_id: message, project_id: project.id)
  def send_email type, options={}
    background_jobs.enqueue(:send_email, type: type, options: options)
  end

end

