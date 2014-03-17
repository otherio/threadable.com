class AddingUniqueIndexOnConversationsSlug < ActiveRecord::Migration
  def change
    # find all conversations with duplicate slugs
    conversations_by_slug = Conversation.
      joins('LEFT JOIN conversations as c2 ON c2.slug = conversations.slug AND c2.id != conversations.id').
      where('c2.id IS NOT NULL').to_a.group_by(&:slug)

    # update the slug letting the, now fixed, acts_as_url properly unique the slug
    conversations_by_slug.each do |slug, conversations|
      conversations.sort_by!(&:created_at).reverse.each do |conversation|
        Conversation.find(conversation.id).update slug: slug
      end
    end

    add_index "conversations", ["organization_id", "slug"], unique: true
  end
end
