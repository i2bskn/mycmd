# Mycmd

[![Gem Version](https://badge.fury.io/rb/mycmd.png)](http://badge.fury.io/rb/mycmd)
[![Build Status](https://travis-ci.org/i2bskn/mycmd.png?branch=master)](https://travis-ci.org/i2bskn/mycmd)
[![Coverage Status](https://coveralls.io/repos/i2bskn/mycmd/badge.png)](https://coveralls.io/r/i2bskn/mycmd)
[![Code Climate](https://codeclimate.com/github/i2bskn/mycmd.png)](https://codeclimate.com/github/i2bskn/mycmd)

MySQL command line tool.

## Installation

Add this line to your application's Gemfile:

    gem 'mycmd'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mycmd

## Settings

Create settings file:

    $ touch ~/.mycmd.yml
    $ mycmd config edit

Setting is the same as the argument of `Mysql2::Client.new`.

Sample settings:

```
host: localhost
port: 3306
username: root
password: secret
tasks:
  slow: SELECT start_time, db, query_time, rows_sent, sql_text FROM mysql.slow_log WHERE db != 'mysql' ORDER BY start_time DESC LIMIT 30
```

## Usage

Start sql shell:

    $ mycmd console
    mysql>

Execute sql:

    $ mycmd query "SELECT * FROM somedb.sometable"
    $ mycmd tasks slow

#### Config Commands

Print current config file path:

    $ mycmd config which

Print current config:

    $ mycmd config cat

Edit config file:

    $ mycmd config edit

#### Setting Commands

Search settings:

    $ mycmd settings search innodb_buffer_pool_size

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
