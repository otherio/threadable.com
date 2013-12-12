# encoding: UTF-8

class String
  ASCII_CHARACTERS = /[^[:ascii:]]/
  def strip_non_ascii replacement=""
    self.gsub(ASCII_CHARACTERS,replacement)
  end
  def strip_non_ascii! replacement=""
    self.gsub!(ASCII_CHARACTERS,replacement)
  end
end

