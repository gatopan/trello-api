require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Interface
  ENTITY_TYPES = {
    MULTIVERSE: 0,
    PERSON:     10,
    COMPANY:    20,
    BOARD:      30,
    LIST:       40,
    CARD:       50,
    ITEM:       60
  }
  ENTITY_ATTRIBUTE_TYPES = [
    {
      name: :string,
      postgresql_type: :string,
      tester_proc: Proc.new{|target| target.class <= String },
      enum_value: 0
    },
    {
      name: :text,
      postgresql_type: :text,
      tester_proc: Proc.new{|target| target.class <= String },
      enum_value: 10
    },
    {
      name: :integer,
      postgresql_type: :integer,
      tester_proc: Proc.new{|target| target.class <= Integer },
      enum_value: 20
    },
    {
      name: :float,
      postgresql_type: :float,
      tester_proc: Proc.new{|target| target.class <= Float },
      enum_value: 30
    },
    {
      name: :boolean,
      postgresql_type: :boolean,
      tester_proc: Proc.new{|target| [TrueClass, FalseClass].include?(target.class) },
      enum_value: 40
    },
    {
      name: :date,
      postgresql_type: :date,
      tester_proc: Proc.new{|target| target.class <= Date },
      enum_value: 50
    },
    {
      name: :datetime,
      postgresql_type: :datetime,
      tester_proc: Proc.new{|target| target.class <= DateTime },
      enum_value: 60
    },
    {
      name: :binary,
      postgresql_type: :binary,
      tester_proc: Proc.new{|target| target.class <= Object },
      enum_value: 70
    },
    {
      name: :symbol,
      postgresql_type: :string,
      tester_proc: Proc.new{|target| target.class <= Symbol},
      enum_value: 80
    }
  ]
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.autoload_paths << "#{Rails.root}/app/decorators"
  end
end
