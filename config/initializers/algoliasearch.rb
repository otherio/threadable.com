AlgoliaSearch.configuration = {
  application_id: ENV.fetch('THREADABLE_ALGOLIA_APPLICATION_ID'),
  api_key:        ENV.fetch('THREADABLE_ALGOLIA_API_KEY'),
}


module AlgoliaSearch::ClassMethods
  def algolia_index_name
    "#{Rails.env}-#{table_name}"
  end
end
