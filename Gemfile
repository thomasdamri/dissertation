source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
git_source(:gitlab) { |repo_name| "git@git.shefcompsci.org.uk:#{repo_name}.git" }

ruby '2.6.6'

# Development Gems (Ensure commented out in production env)

# source "https://gems.shefcompsci.org.uk" do
#   gem 'airbrake'
#   gem 'rubycas-client'
#   gem 'epi_cas'
# end


gem 'airbrake', github: 'epigenesys/airbrake', branch: 'airbrake-v4'
gem 'rubycas-client', gitlab: 'gems/rubycas-client'
gem 'epi_js'


# Production gems (Ensure commented out in development env)

gem 'rubycas-client', git: 'git@git.shefcompsci.org.uk:gems/rubycas-client.git'
gem 'epi_cas', git: 'git@git.shefcompsci.org.uk:gems/epi_cas.git'

# Need a relatively new version of nokogiri due to low severity vulnerability
gem "nokogiri", ">= 1.11.0"
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3', '>= 6.0.3.3'

# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.4.10'


# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
#gem 'arel'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Needed for sending emails
gem 'delayed_job_active_record'
gem "letter_opener", :group => :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Paginating large lists of db models
gem 'will_paginate', '~> 3.1.0'

# Login authentication
gem 'devise'
# Authorization
gem 'cancancan'
# Use HAML files instead of ERBs
gem 'haml-rails', '~> 2.0'
# Provides helpers for rails forms
gem 'simple_form'
# Provides easy interaction with TSV files (for CEIS output uploading)
gem 'tsv'



group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 4.0.1'
  gem 'factory_bot_rails'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'annotate'

  # Using capistrano for deployment
  gem "capistrano", "~> 3.10", require: false
  gem "capistrano-rails", "~> 1.6", require: false

end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
  # Coverage checker
  gem 'simplecov', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
