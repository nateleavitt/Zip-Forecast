require_relative "boot"

require "action_controller/railtie"
require "action_view/railtie"
require "active_job/railtie"
require "active_storage/engine"
require "action_cable/engine"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ZipForecast
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Memcached settings
    config.action_controller.perform_caching = true
    config.cache_store =
      :mem_cache_store,
      "#{ENV['MEMCACHED_SERVICE_HOST']}:#{ENV['MEMCACHED_SERVICE_PORT']}",
      { compress: true, namespace: "app", raise_erros: true }
  end
end
