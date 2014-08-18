# ChatworkTo

ChatWorkTo can transfer ChatWork messages via notifier.

## Installation

Add this line to your application's Gemfile:

    gem 'chatwork_to'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chatwork_to

## Usage
### Setup chatwork_to.yml
Create configuration file named `chatwork_to.yml` in `./` or `~/` directory. Required configuration are:
```
chatwork:
  email: 'email'
  pass:  'password'
  rooms:
    - 'room id'
```
`rooms` is array for multiple room id.

## Notifiers
### Simple
Simple Notifier which is based on Ruby Logger is output to `$stdout`.
```
notifiers:
  -
    name: simple
```
If used `io` option, logger output to file. `rotation`(Default:`weekly`) option is compliant with the rotation option of Ruby Logger.
```
notifiers:
  -
    name: simple
    io: '~/logs/chatwork_to.log'
    rotation: weekly
```

### Slack
Slack Notifier forwards to Slack messages of ChatWork via Slack API.
```
notifiers:
  -
    name: slack
    token: 'API authentication token'
    channel: 'public channel or private group or @user'
```

## Run
### Foreground
```
$ chatwork_to
```

### Daemon
Using [daemons](https://rubygems.org/gems/daemons 'daemos').
```
$ chatwork_to start
```
```
$ chatwork_to stop
```
```
$ chatwork_to restart
```
```
$ chatwork_to status
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/chatwork_to/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
