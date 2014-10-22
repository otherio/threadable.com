class Inbox

  include Enumerable

  def initialize user
    @messages = Messages.new
    @user = user
  end

  attr_reader :user

  delegate :size, :delete, to: :@messages

  def each &block
    @messages.each(&block)
  end

  def delete_all
    # NVLOPE.messages.delete map(&:id) Nvlope is long dead :(
    self
  end

  def reload
    # NVLOPE.messages.query(to: user.email_address).each do |message| Nvlope is long dead :(
      @messages.add Message.new(self, message)
    end
    self
  end

  def find_all options={}
    options.inject(@messages) do |messages, (attribute, value)|
      messages.send(attribute, value)
    end
  end

  def find options={}
    find_all(options).first
  end

  def find! options={}
    find(options).presence or raise "message not found from:\n#{options.inspect}"
  end

  def wait_for_message options={}
    timeout = options.delete(:timeout) || 60.seconds
    start_time = Time.now
    message = nil
    until Time.now - start_time > timeout
      message = find(options) and break or reload
      sleep 1
    end
    message
  end

  def inspect
    %(#<#{self.class} (#{@messages.size})>)
  end


  class Messages < Set

    def select *args, &block
      self.class.new super
    end

    def subject subject
      Regexp === subject ?
      select{|email| Array(email.subject).first =~ subject } :
      select{|email| Array(email.subject).first == subject }
    end

  end

  class Message

    def initialize inbox, message
      @inbox, @message = inbox, message
    end

    delegate *%w{
      == id subject html_part text_part text header created_at header sender recipients
    }, to: :@message

    def delete
      @message.delete and @inbox.delete(self)
    end

    def html
      @html ||= Nokogiri.parse html_part
    end

    def links
      html.css('a[href]')
    end

    def href_for_link text
      link = (links.find{|link| link.text == text} or return)
      link[:href]
    end

  end

end
