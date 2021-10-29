require_relative 'boot'

require 'rails/all'
require "active_record/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Require gems used by epi_cas
require 'devise'
require 'devise_cas_authenticatable'
require "devise_ldap_authenticatable"
require 'sheffield_ldap_lookup'
module Teamassess
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
