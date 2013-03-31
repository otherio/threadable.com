# Multify

## Install

#### Install Redis

    brew install redis

#### Install Postgress

    brew install postgres



## Heroku

### Config Vars

We rely on a number of custom heroku config variables

    BUILDPACK_URL:              https://github.com/heroku/heroku-buildpack-ruby
    DATABASE_URL:               postgres://…
    HEROKU_POSTGRESQL_JADE_URL: postgres://…
    MULTIFY_CLEF_ID:            …
    MULTIFY_CLEF_SECRET:        …
    MULTIFY_PASSWORD:           …
    REDISCLOUD_URL:             redis://rediscloud…

We need the latest version of the ruby build pack in order to allow us to have `config.assets.initialize_on_precompile` enabled which we need to compile our routes into JavaScript.

### Git remotes

To configure your git remotes, run:
script/setup_remotes

### Pushing

To push to staging, run:
script/deploy

To push to production, run:
script/deploy production
