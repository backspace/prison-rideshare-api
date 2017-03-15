# Prison Rideshare [![Build Status](https://travis-ci.org/backspace/prison-rideshare.svg?branch=primary)](https://travis-ci.org/backspace/prison-rideshare-api)

This is a database to track reïmbursements and miscellania for a prison rideshare project.

It’s intended to replace an increasingly unwieldy and brittle set of spreadsheets.

The initial target feature set will cover:
* coördinators recording ride requests
* ride-givers completing reports on their rides
* collecting and calculating gas and food expenses from the reports
* tracking reïmbursements of expenses

It’s currently specific to [Bar None’s prison rideshare project](https://barnoneblog.wordpress.com/rideshare/) but if you’re
interested in adapting it, please let us know, we are interested in making it useful for others!

## Deployment

This can be deployed to Heroku and Postgres. More on that to come. Required environment variables:

* `MAILGUN_KEY`

Currently hardcoded:

* Mailgun domain
* currency

## Running

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
