# Mycmd

[![Code Climate](https://codeclimate.com/github/i2bskn/mycmd.png)](https://codeclimate.com/github/i2bskn/mycmd)

MySQL command line tool.

## Installation

Add this line to your application's Gemfile:

    gem 'mycmd'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mycmd

Create settings file:

    $ touch ~/.mycmd.yml
    $ mycmd config edit

## Usage

Start sql shell:

    $ mycmd console
    mysql>

Execute sql:

    $ mycmd query "SELECT * FROM somedb.sometable"

#### Config Commands

Print current config file path:

    $ mycmd config which

Print current config:

    $ mycmd config cat

Edit config file:

    $ mycmd config edit

#### Setting Commands

Search settings:

    $ mycmd setting search innodb_buffer_pool_size

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
