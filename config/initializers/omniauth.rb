Rails.application.config.middleware.use OmniAuth::Builder do
  provider :trello, ENV['THREADABLE_TRELLO_API_KEY'], ENV['THREADABLE_TRELLO_API_SECRET'],
  app_name: "Threadable", scope: 'read,write,account', expiration: 'never'
end
