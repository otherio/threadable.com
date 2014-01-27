# Covered
[![Code Climate](https://codeclimate.com/repos/529ae91f13d6370300012943/badges/b09a4700ab1a7948a0d9/gpa.png)](https://codeclimate.com/repos/529ae91f13d6370300012943/feed)
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
    COVERED_CLEF_ID:            …
    COVERED_CLEF_SECRET:        …
    COVERED_PASSWORD:           …
    COVERED_MAILGUN_KEY:        …
    COVERED_MAILGUN_PASSWORD:   …
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
