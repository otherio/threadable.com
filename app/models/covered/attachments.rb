class Covered::Attachments < Covered::Collection

  extend ActiveSupport::Autoload

  autoload :Create

  def all
    scope.reload.map{ |attachment_record| attachment_for attachment_record }
  end

  def build attributes
    attachment_for scope.build(attributes)
  end
  alias_method :new, :build

  private

  def scope
    ::Attachment.all
  end

  def attachment_for attachment_record
    Covered::Attachment.new(covered, attachment_record)
  end

end
