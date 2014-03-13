module TrackingConcern

  extend ActiveSupport::Concern

  def mixpanel_cookie
    @mixpanel_cookie ||= MixpanelCookie.new(cookies)
  end

  def mixpanel_distinct_id
    mixpanel_cookie.distinct_id
  end

  def ensure_mixpanel_distinct_id_is_correct!
    if signed_in?
      mixpanel_cookie.distinct_id = current_user_id
    else
      mixpanel_cookie.reset! if mixpanel_cookie.distinct_id.length < 20
    end
  end

  class MixpanelCookie
    MIXPANEL_COOKIE_NAME = "mp_#{ENV.fetch('MIXPANEL_TOKEN')}_mixpanel"

    def initialize cookies
      @cookies = cookies
    end

    def to_hash
      @hash ||= JSON.parse(@cookies[MIXPANEL_COOKIE_NAME] || '{}')
    end

    def [] key
      to_hash[key.to_s]
    end

    def []= key, value
      update(key => value)
    end

    def update hash
      to_hash.update(hash.stringify_keys)
      write_cookie!
    end

    def delete!
      @hash = nil
      @cookies.delete(MIXPANEL_COOKIE_NAME)
    end

    def reset!
      @hash = {}
      distinct_id
      write_cookie!
    end

    def distinct_id
      self['distinct_id'] ||= SecureRandom.uuid
    end

    def distinct_id= distinct_id
      self['distinct_id'] = distinct_id
    end

    private

    def write_cookie!
      @cookies[MIXPANEL_COOKIE_NAME] = to_hash.to_json
    end

  end

end
