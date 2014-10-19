class UpdateRealtimeToken < MethodObject

  def call threadable, session
    @session = session
    @threadable = threadable
    user_id = threadable.current_user_id

    session_data = {
      user_id: user_id,
      organization_ids: threadable.current_user.organizations.all.map(&:id)
    }.to_json

    Threadable.redis.hset(
      "realtime_session-#{user_id}",
      realtime_token,
      session_data
    )

    Threadable.redis.expire("realtime_session-#{realtime_token}", 86400)
    realtime_token
  end

  attr_reader :session, :threadable

  private

  def realtime_token
    @realtime_token ||= Digest::SHA1.hexdigest("#{session[:session_id]}:#{threadable.current_user_id}")
  end
end
