# Lidarr

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/lidarr`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add lidarr

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install lidarr

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/lidarr. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/lidarr/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Lidarr project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/lidarr/blob/main/CODE_OF_CONDUCT.md).

# Links

* [testdouble-standard](https://github.com/testdouble/standard)

# Configs

Looks in: `/etc/lidarr-cli.yml`, `~/.config/lidarr/cli.yml`, anything pointed at by `$LIDARR_CONFIG`.

Looks at yaml keys:

* `api_key`
* `headers`
* `secure`
* `url`
* `verbose`

Below is a sample yaml config at `~/.config/lidarr/cli.yml`

```yaml
---
api_key: "blahblahblahblah"
headers:
  - "host: my.homelab.net"
url: "https://172.16.1.15/lidarr"
secure: false
```

# Done

* `lidarr album monitor ID[,ID*]`
* `lidarr album unmonitor ID[,ID*]`
* `lidarr album get_by_artist_id ID`
* `lidarr album get_by_album_id ID[,ID*]`
* `lidarr album get_by_foreign_album_id ID`
* `lidarr album search TERM`
* `lidarr artist get ID`
* `lidarr artist list`
* `lidarr artist search TERM`
* `lidarr tag get [ID] [--details]`
* `lidarr wanted cutoff [ID] [--include-artist]`
* `lidarr wanted missing [ID] [--include-artist]`

# TODO

* Create classes from json schema instead of code
* lidarr artist edit --monitor=true/false --monitor-new-albums=enum --quality-profile=ID --metadata-profile=ID artistId
* Good tests
* blocklist
* Check the queue, delete from the queue, clear the queue
* Validate cli configs before using them
* Replace HTTParty with just a small Net/HTTP wrapper
