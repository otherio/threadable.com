Rails.application.config.middleware.use OmniAuth::Builder do
  provider :trello,
    ENV['THREADABLE_TRELLO_API_KEY'],
    ENV['THREADABLE_TRELLO_API_SECRET'],
    app_name: "Threadable",
    scope: 'read,write,account',
    expiration: 'never'

  provider :google_oauth2,
    ENV["GOOGLE_CLIENT_ID"],
    ENV["GOOGLE_CLIENT_SECRET"],
    scope: "email, profile, admin.directory.group, apps.groups.settings",
    prompt: 'consent',
    access_type: 'offline'
end
