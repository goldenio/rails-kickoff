$LOAD_PATH << File.expand_path('../..', __FILE__)

# helpers

require 'rails/kickoff'

extend Rails::Kickoff::Helper

# actions

extend Recipes::Assets
extend Recipes::Authentication
extend Recipes::Authorization
extend Recipes::Common
extend Recipes::Console
extend Recipes::Form
extend Recipes::GoldenTheme
extend Recipes::Meter
extend Recipes::Rendering
extend Recipes::Server
extend Recipes::Testing

# runs

add_source_paths templates_path('goldenio_app')
read_rc_file '~/.goldenio_kickoff'
initial_commit
rvm_use_ruby_version
git_ignore_database_and_secrets
apply_rspec
apply_database_cleaner
apply_capybara
apply_fabrication
apply_faker
apply_simplecov
# apply_shoulda_matchers
apply_pry
apply_awesome_print
apply_hirb
# apply_better_errors
apply_rack_mini_profiler
# apply_rails_best_practices
apply_rails_i18n
apply_devise
add_devise_ext
apply_cancancan
apply_simple_form
apply_responders
apply_bootstrap_sass
adjust_application_layout
add_home_page
apply_golden_theme
add_custom_devise_views
add_custom_generators
apply_foreman
# apply_powder
apply_role_and_role_owner
apply_slim
run_specs
create_develop_branch
