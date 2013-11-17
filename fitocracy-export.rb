require 'rubygems'
require 'bundler/setup'

require 'optparse'

$LOAD_PATH << './lib'
require 'fitocracy_scraper'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: fitocracy-export.rb [options]"

  opts.on("-u", "--username [USERNAME]", "Fitocracy username") do |username|
    options[:username] = username
  end

  opts.on("-p", "--password [PASSWORD]", "Fitocracy password") do |password|
    options[:password] = password
  end
end.parse!

scraper = FitocracyScraper.new(options[:username], options[:password])
scraper.log_in
scraper.export_all
