require 'rubygems'
require 'bundler/setup'

require 'capybara'
require 'capybara/poltergeist'
require 'capybara/dsl'
require 'capybara-screenshot'

require 'optparse'

class FitocracyScraper
  include Capybara::DSL
  include Capybara::Screenshot

  def initialize(username, password)
    @username = username
    @password = password

    Capybara.current_driver = :poltergeist
    Capybara.app_host = 'http://www.fitocracy.com'
    Capybara.default_wait_time = 10
  end

  def log_in
    print "Logging in... "
    visit '/'
    click_on "Log in"
    find('.login-username-link').click

    within '#username-login-modal' do
      fill_in :username, with: @username
      fill_in :password, with: @password

      click_on "Log in"
    end

    wait_for_home_page_load
    puts "success!"
  end

  def export_all
    visit_performance_page

    exercise_list.each do |exercise|
      export_exercise(exercise)
    end
  end

  def screenshot
    screenshot_and_open_image
  end

  private
  def export_exercise(name)
    print "exporting #{name} ... "

    select name
    click_on "CSV"

    within_window page.driver.browser.window_handles.last do
      csv = current_csv
      filename = "#{name.gsub(' ', '-').downcase}.csv"
      File.open(filename, 'w') { |file| file.write(csv) }

      puts "wrote #{csv.split("\n").length - 1} sets to #{filename}"
    end

  end

  def current_csv
    page.body.match(/<pre[^>]*>(.*)<\/pre>/m)[1]
  end

  def exercise_list
    all("select#history_activity_chooser option").to_a.map do |option|
      option.text
    end
  end

  def visit_performance_page
    visit "/profile/#{@username}/?performance"
    wait_for_performance_page_load
  end

  def wait_for_performance_page_load
    wait_until { page.has_css? "select#history_activity_chooser" }
  end

  def wait_until
    Timeout.timeout(Capybara.default_wait_time) do
      loop { break if yield }
    end
  end

  def wait_for_home_page_load
    wait_until { page.has_css? '#home-feed-nav' }
  end

end


options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: export.rb [options]"

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
