class Message < ActiveRecord::Base

  include AlgoliaSearch
  algoliasearch do
    attribute(
      :id,
      :organization_id,
      :conversation_id,
      :conversation_type,
      :conversation_subject,
      :conversation_updated_at,
      :conversation_group_ids,
      :creator_name,
      :creator_email_address,
      :created_at,
      :updated_at,
      :body_plain_for_search,
      :body_html_for_search,
    )

    attributesToIndex %w(
      unordered(conversation_subject)
      unordered(body_plain_for_search)
      unordered(creator_name)
      unordered(creator_email_address)
    )

    attributesForFaceting %w(organization_id conversation_type)
    attributeForDistinct  'id'
    ranking               %w(custom)
    customRanking         %w(desc(conversation_updated_at))

    tags do
      ["organization_#{organization_id}", "conversation_#{conversation_id}"] +
        conversation_group_ids.map{|id| "group_#{id}" }
    end
  end

  belongs_to :conversation, counter_cache: true
  belongs_to :parent_message, class_name: 'Message', foreign_key: 'parent_id'
  belongs_to :creator, class_name: 'User', foreign_key: 'user_id'
  has_one :organization, through: :conversation
  has_and_belongs_to_many :attachments, class_name: 'Attachment'
  has_many :sent_emails

  scope :by_created_at, ->{ order('messages.created_at DESC') }

  scope :not_sent_to, ->(user_id){
    user_id = Message.sanitize(user_id)
    joins("LEFT JOIN sent_emails ON messages.id = sent_emails.message_id AND sent_emails.user_id = #{user_id}").
    where('sent_emails.id IS NULL')
  }

  before_create :touch_conversation_update_at

  validates_presence_of :conversation_id, :date_header, :message_id_header

  def creator_id
    self.user_id
  end

  def creator_id= id
    self.user_id= id
  end

  def parent_message_id
    self.parent_id
  end

  def parent_message_id= id
    self.parent_id= id
  end

  def unique_id
    Base64.urlsafe_encode64 message_id_header
  end

  def organization_id
    organization.id
  end

  def conversation_type
    conversation.type
  end

  def conversation_subject
    conversation.subject
  end

  def conversation_updated_at
    conversation.updated_at
  end

  def conversation_group_ids
    conversation.groups.map(&:id)
  end

  def creator_name
    creator && creator.name
  end

  def creator_email_address
    creator && creator.email_address
  end

  def body_html_for_search
    StripHtml.call(body_html)[0...(9728-body_plain_for_search.length)]
  end

  def body_plain_for_search
    @body_plain_for_search ||= body_plain[0...9728]
  end

  private

  def touch_conversation_update_at
    conversation.touch(:updated_at)
  end

end
