module DebugCookie
  extend ActiveSupport::Concern

  SECRET = '0515fc548e828f73847ecc0c6247b1e38e7fedcc'.freeze

  included do
    helper_method :debug_enabled?
  end

  def debug_enabled?
    cookies[:debug] == SECRET
  end

  def enable_debug!
    cookies[:debug] = SECRET
  end

  def disable_debug!
    cookies.delete(:debug)
  end

end
