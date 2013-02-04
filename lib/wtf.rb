class Object

  def wtf!
    raise __wtf__
  end

  def log! message = nil, color = :red
    Rails.logger.debug __wtf_colorized__(message, color)
    return self
  end

  def puts! message = nil, color = :red
    puts __wtf_colorized__(message, color)
    return self
  end

  protected

  def __wtf__
    (self.respond_to?(:pretty_inspect) ? self.pretty_inspect : self.inspect)
  end

  def __wtf_colorized__ message = nil, color = :red
    line = colorize_if_possible(__wtf__.chomp, color: color, background: :light_yellow)
    message = message.to_s if message.is_a? Symbol
    line = colorize_if_possible("#{message}:", color: color, background: :white) +' '+ line if message.is_a? String
    line = line + colorize_if_possible("\n#{caller[1]}\n", color: :red, background: :black)
    "\n#{line}\n"
  end

  # This is to remove the dependency on colorize, if you want to use this outside our app.
  def colorize_if_possible(string, colorize_options)
    return string unless string.respond_to?(:colorize)
    string.colorize(colorize_options)
  end

end
