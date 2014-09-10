class Threadable::Settings < Threadable::Model

  attr_reader :model, :settings

  def initialize settings
    @settings = settings

    settings.keys.each do |setting|
      self.class.send(:define_method, setting) do
        get(setting)
      end
    end
  end

  def settable? setting
    # override this in your subclass.
    true
  end

  alias_method :gettable?, :settable?

  def set setting, value
    raise Threadable::AuthorizationError, 'You cannot set that parameter with your current plan' unless settable?(setting)
    model.update_attribute(setting, options_for(setting).index(value))
  end

  def get setting
    return default_for(setting) unless gettable?(setting)
    offset = model.send(setting)
    options_for(setting)[offset]
  end

  private

  def options_for setting
    settings[setting][:options]
  end

  def default_for setting
    settings[setting][:default]
  end
end
