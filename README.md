# Milkode

[![Build Status](https://travis-ci.org/ongaeshi/milkode.svg?branch=develop)](https://travis-ci.org/ongaeshi/milkode)

Milkode is "Line Based" local source code search engine written by Ruby. It have command line interface and web application. It will accelerate the code reading of your life.

Milkode is "見るコード". "See a code" is meaning.

[Honyomi](https://github.com/ongaeshi/honyomi) are brothers.

![milk-web-01.jpg](http://milkode.ongaeshi.me/images/milk-web-01.jpg)

## Installation

    $ gem install milkode

When you faild to install Rroonga, Please refer.
* [File: install — rroonga - Ranguba](http://ranguba.org/rroonga/en/file.install.html)

## Usage

### Create a database

```
$ milk init --default
create     : /Users/auser/.milkode/milkode.yaml
create     : /Users/auser/.milkode/db/milkode.db created.
```

Create database to current dir.

```
$ milk init
Create database to "/path/to/dir/db/honyomi.db"
```

If you want to use custom database, Please specify `MILKODE_DEFAULT_DIR` variable.

```
$ MILKODE_DEFAULT_DIR=/path/to/dir milk add /path/to/project
```

### Add packages

```
# Add source code from local directory
$ milk add a_project/
package    : a_project
add_record : /Users/auser/Documents/a_project/a.txt
add_record : /Users/auser/Documents/a_project/b.txt
add_record : /Users/auser/Documents/a_project/c.rb
result     : 1 packages, 3 records, 3 add. (0.21sec)
*milkode*  : 1 packages, 3 records in /Users/auser/.milkode/db/milkode.db.

# Add source code from gem
$ milk add /opt/local/lib/ruby2.0/gems/2.0.0/gems/milkode-1.6.2/

# Add source code from GitHub
$ milk add https://github.com/ongaeshi/milkode.git -p git
$ milk add git://github.com/ongaeshi/milkode.git
$ milk add git://github.com/ongaeshi/milkode.git -b develop -n milkode_develop

# Add source code from http-zip
$ milk add http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.zip
```

### List packages

```
$ milk list
a_project
milkode
milkode-1.6.2
ruby-2.1.2

# Filter by keyword
$ milk list milk
milkode-1.6.2
milkode
```

## Documents

* [Milkode - line based local source code search engine](http://milkode.ongaeshi.me/)

## Plugins

* [emacs-milkode](https://github.com/ongaeshi/emacs-milkode)
* [anything-milkode](https://github.com/ongaeshi/anything-milkode)

## HISTORY

* [History.rdoc](https://github.com/ongaeshi/milkode/blob/master/HISTORY.rdoc)
* [更新履歴](https://github.com/ongaeshi/milkode/blob/master/HISTORY.ja.rdoc)

