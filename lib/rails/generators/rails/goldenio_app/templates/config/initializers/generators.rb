# Set options for generators
Rails.application.config.generators do |g|
  g.orm :active_record
  g.assets stylesheet_engine: :sass,
           stylesheets: false,
           javascripts: false
  g.scaffold stylesheet_engine: :sass,
             stylesheets: false,
             assets: false,
             helper: false
  g.helper false
  g.jbuilder false
  g.test_framework :rspec
  # g.view_specs false
  # g.helper_specs false
  # g.fixture_replacement :factory_girl, dir: 'spec/factories'
end
