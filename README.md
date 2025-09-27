# Prison Rideshare [![pipeline status](https://github.com/backspace/prison-rideshare-api/actions/workflows/ci.yml/badge.svg)](https://github.com/backspace/prison-rideshare-api) [![Coverage Status](https://coveralls.io/repos/github/backspace/prison-rideshare-api/badge.svg?branch=primary)](https://coveralls.io/github/backspace/prison-rideshare-api?branch=primary)

This is a database to track reïmbursements and miscellania for a prison rideshare project. It serves the API for the [Ember UI](https://github.com/backspace/prison-rideshare-ui).

It’s intended to replace an increasingly unwieldy and brittle set of spreadsheets.

The initial target feature set will cover:

- coördinators recording ride requests
- ride-givers completing reports on their rides
- collecting and calculating gas and food expenses from the reports
- tracking reïmbursements of expenses

It’s currently specific to [Bar None’s prison rideshare project](https://barnonewpg.org/rideshare/) but if you’re
interested in adapting it, please let us know, we are interested in making it useful for others!

## Deployment

This can be deployed to various environments but [Dokku](https://dokku.com) is the current iteration.

## Set up

```bash
dokku apps:create rideshare-api
dokku buildpacks:add rideshare-api https://github.com/gigalixir/gigalixir-buildpack-elixir.git

dokku postgres:create rideshare-api
dokku postgres:link rideshare-api rideshare-api
```

### Add environment variables

- `DATABASE_URL` (set automatically by `postgres:link`)
- `MAILGUN_KEY`: to send transactional email (ride reports, calendar links, warnings)
- `ORIGIN_HOST`: domain application will be served at
- `SECRET_KEY_BASE`: use `mix phx.gen.secret` to generate
- `SENTRY_DSN`: for error-monitoring

```bash
dokku config:set rideshare-api \
  MAILGUN_KEY= \
  ORIGIN_HOST= \
  SECRET_KEY_BASE= \
  SENTRY_DSN=
```

Currently hardcoded:

- Mailgun domain
- currency

### Deploy

```bash
git remote add [remote name] dokku@[host]:rideshare-api
git push [remote name] primary
```

## Running

To start your Phoenix app:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.create && mix ecto.migrate`
- Install Node.js dependencies with `npm install`
- Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

- Official website: http://www.phoenixframework.org/
- Guides: http://phoenixframework.org/docs/overview
- Docs: https://hexdocs.pm/phoenix
- Mailing list: http://groups.google.com/group/phoenix-talk
- Source: https://github.com/phoenixframework/phoenix
