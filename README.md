# Rails Kickoff

Kick off rails application by rails templates.

## Installation

Install it via git:

```
$ git clone git@github.com:goldenio/rails-kickoff.git
$ cd rails-kickoff
$ rake install
```

## Usage

Add settings to `~/.goldenio_kickoff`, like

```
DATABASE_PASSWORD=<please_change_it>
MAILER_SENDER=no-reply@goldenio.com
DOMAIN_URL=goldenio.com
DEFAULT_LOCALE=:'zh-TW'
#BUNDLE_OPTION=--local
```

Create rails application with `--skip-bundle` and `--template` options, like

```
rails _4.1.6_ new demo_app -Td mysql --skip-bundle --template ~/.rvm/gems/ruby-2.1.3/gems/rails-kickoff-0.0.1/lib/templates/goldenio.rb
```

## Contributing

1. Fork it ( https://github.com/goldenio/rails-kickoff/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
