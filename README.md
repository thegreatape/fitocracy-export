# Fitocracy Export

A script for exporting your workout data from [Fitocracy](http://www.fitocracy.com). Uses [Poltergeist](https://github.com/jonleighton/poltergeist) and PhantomJS for automation.

## Setup

If you don't have PhantomJS 1.9 installed:

    $ brew install phantomjs

Then install dependencies with Bundler:

    $ bundle install

## Usage

    $ ruby fitocracy-export.rb -u [USERNAME] -p [PASSWORD]

The script will write out your data to a series of CSV files in the current directory.
