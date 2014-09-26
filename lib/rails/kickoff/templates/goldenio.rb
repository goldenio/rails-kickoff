$LOAD_PATH << File.expand_path('../../../..', __FILE__)

# helpers

require 'rails/kickoff'

extend Rails::Kickoff::Helper
extend Rails::Kickoff::Recipes::Console
extend Rails::Kickoff::Recipes::Meter
extend Rails::Kickoff::Recipes::Server
extend Rails::Kickoff::Recipes::Testing

# actions

def initial_commit
  ui.task __method__

  bundle_command "install #{bundle_option}"
  # bundle_command 'exec spring binstub --all'

  # message = [ File.basename($PROGRAM_NAME) ]
  # message += ARGV.dup
  # message = message.join(' ')
  message = 'initial commit'

  git :init
  git add: '-A'
  git commit: "-m '#{message}'"
end

def rvm_use_ruby_version
  ui.task __method__

  run 'rm .ruby-version'
  ruby_version = run("/bin/bash -l -c 'rvm current'", capture: true).strip
  run "/bin/bash -l -c 'rvm --create --ruby-version use #{ruby_version}'"

  message = <<-CODE.strip_heredoc
    rvm --create --ruby-version use #{ruby_version}
  CODE

  git add: '-A'
  git commit: "-m '#{message}'"
end

def git_ignore_database_and_secrets
  ui.task __method__

  empty_directory 'config/examples'

  run 'git rm config/database.yml'
  template "config/databases/#{options[:database]}.yml", "config/examples/database.yml"
  template "config/databases/#{options[:database]}.yml", 'config/database.yml'
  gsub_file 'config/database.yml',
    "password:\n",
    "password: #{@argv['DATABASE_PASSWORD']}\n"

  run 'git mv config/secrets.yml config/examples/secrets.yml'
  template 'config/secrets.yml'

  append_to_file '.gitignore' do
    <<-CODE.strip_heredoc

      # Ignore all secured configurations
      /config/database.yml
      /config/secrets.yml
    CODE
  end

  message = <<-CODE.strip_heredoc
    git ignore database.yml and secrets.yml
  CODE

  git add: '-A'
  git commit: "-m '#{message}'"
end

def apply_rails_i18n
  ui.task __method__

  append_to_file 'Gemfile' do
    <<-CODE.strip_heredoc

      # Use rails-i18n for localization
      gem 'rails-i18n'
    CODE
  end
  bundle_command "install #{bundle_option}"

  inject_into_file 'config/application.rb',
    after: "# config.time_zone = 'Central Time (US & Canada)'\n" do
    "    config.time_zone = 'Taipei'\n"
  end

  inject_into_file 'config/application.rb',
    after: "# config.i18n.default_locale = :de\n" do
    <<-CODE
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.available_locales = [:'zh-TW', :zh, :en]
    config.i18n.default_locale = #{default_locale}
    CODE
  end

  empty_directory 'config/locales/1-gems'

  message = <<-CODE.strip_heredoc
    apply rails-i18n

    set default_locale to #{default_locale}
    set time_zone to Taipei
  CODE

  git add: '-A'
  git commit: "-m '#{message}'"
end

def apply_devise
  ui.task __method__

  rake 'db:drop'
  rake 'db:create'

  append_to_file 'Gemfile' do
    <<-CODE.strip_heredoc
      # Use devise for authentication
      gem 'devise'
    CODE
  end
  bundle_command "install #{bundle_option}"

  generate 'devise:install'
  generate 'devise', 'user'

  inject_into_file 'app/models/user.rb',
    after: ":registerable,\n" do
    "         :confirmable, :lockable, :timeoutable,\n"
  end

  files = Dir.glob "db/migrate/*_devise_create_users.rb"
  gsub_file files.first, "# t.", "t."
  gsub_file files.first, "# add_index", "add_index"

  rake 'db:migrate'

  template 'config/examples/mailer.rb'
  template 'config/examples/mailer.rb', 'config/initializers/mailer.rb'
  comment_lines 'config/initializers/mailer.rb',
    "location: '/usr/sbin/exim4'"
  comment_lines 'config/initializers/mailer.rb',
    "arguments: '-i'"

  inject_into_file '.gitignore',
    after: "# Ignore all secured configurations\n" do
    "/config/initializers/mailer.rb\n"
  end

  run 'mv config/locales/devise.en.yml config/locales/1-gems'
  copy_file 'config/locales/1-gems/devise.zh-TW.yml'
  copy_file 'config/locales/users.en.yml'
  copy_file 'config/locales/users.zh-TW.yml'

  copy_file 'spec/support/devise.rb'
  copy_file 'spec/support/requests_extension.rb'

  message = <<-CODE.strip_heredoc
    apply devise

    rake db:create
    rails g devise:install
    rails g devise user
    rake db:migrate
    add config/initializers/mailer.rb
  CODE

  git add: '-A'
  git commit: "-m '#{message}'"
end

def add_devise_ext
  ui.task __method__

  inject_into_file 'app/controllers/application_controller.rb',
    after: "class ApplicationController < ActionController::Base\n" do
    "  include DeviseExt\n\n"
  end

  copy_file 'app/controllers/concerns/devise_ext.rb'
  copy_file 'app/models/user_parameter_sanitizer.rb'

  message = <<-CODE.strip_heredoc
    add devise_ext concern

    add user_parameter_sanitizer model
  CODE

  git add: '-A'
  git commit: "-m '#{message}'"
end

def apply_cancancan
  ui.task __method__

  append_to_file 'Gemfile' do
    <<-CODE.strip_heredoc

      # Use cancancan for authorization
      gem 'cancancan'
    CODE
  end
  bundle_command "install #{bundle_option}"

  copy_file 'app/controllers/concerns/cancan_ext.rb'

  inject_into_file 'app/controllers/application_controller.rb',
    after: "include DeviseExt\n" do
    "  include CancanExt\n"
  end

  copy_file 'app/models/ability.rb'

  inject_into_file 'config/application.rb',
    before: "  end\n" do
    <<-CODE

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(
      #\{config.root\}/app/abilities
    )
    CODE
  end

  copy_file 'app/abilities/anonymous_ability.rb'
  copy_file 'app/abilities/member_ability.rb'

  copy_file 'config/locales/1-gems/cancancan.zh-TW.yml'

  inject_into_file 'spec/rails_helper.rb',
    after: "# Add additional requires below this line. Rails is not loaded until this point!\n" do
    "require 'cancan/matchers'\n"
  end

  message = <<-CODE.strip_heredoc
    apply cancancan
  CODE

  git add: '-A'
  git commit: "-m '#{message}'"
end

def apply_simple_form
  ui.task __method__

  append_to_file 'Gemfile' do
    <<-CODE.strip_heredoc

      # Use simple_form as form builder
      gem 'simple_form', '~> 3.1.0.rc2'
    CODE
  end
  bundle_command "install #{bundle_option}"

  generate 'simple_form:install', '--bootstrap'

  run 'mv config/locales/simple_form.en.yml config/locales/1-gems'
  copy_file 'config/locales/1-gems/simple_form.zh-TW.yml'

  message = <<-CODE.strip_heredoc
    apply simple_form

    rails g simple_form:install --bootstrap'
  CODE

  git add: '-A'
  git commit: "-m '#{message}'"
end

def apply_responders
  ui.task __method__

  append_to_file 'Gemfile' do
    <<-CODE.strip_heredoc

      # Use responders for flash & cache responder
      gem 'responders'
    CODE
  end
  bundle_command "install #{bundle_option}"

  generate 'responders:install'

  run 'mv config/locales/responders.en.yml config/locales/1-gems'
  copy_file 'config/locales/1-gems/responders.zh-TW.yml'

  message = <<-CODE.strip_heredoc
    apply responders

    rails g responders:install
  CODE

  git add: '-A'
  git commit: "-m '#{message}'"
end

def apply_bootstrap_sass
  ui.task __method__

  append_to_file 'Gemfile' do
    <<-CODE.strip_heredoc

      # Use bootstrap-sass for view layout
      gem 'bootstrap-sass'

      # Use autoprefixer-rails to add browser vendor prefixes
      gem 'autoprefixer-rails'
    CODE
  end
  bundle_command "install #{bundle_option}"

  inject_into_file 'app/assets/javascripts/application.js',
    before: "//= require_tree .\n" do
    "//= require bootstrap-sprockets\n"
  end

  copy_file 'app/assets/stylesheets/bootstrap_custom.css.sass'

  inject_into_file 'app/assets/stylesheets/application.css',
    before: " *= require_tree .\n" do
    " *= require bootstrap_custom\n"
  end

  message = <<-CODE.strip_heredoc
    apply bootstrap-sass
  CODE

  git add: '-A'
  git commit: "-m '#{message}'"
end

def adjust_application_layout
  ui.task __method__

  directory 'vendor/assets/javascripts/html5shiv'
  directory 'vendor/assets/javascripts/respondjs'

  append_to_file 'config/initializers/assets.rb' do
    <<-CODE.strip_heredoc
      Rails.application.config.assets.precompile += %W(
        html5shiv/html5shiv-printshiv.js
        html5shiv/html5shiv.js
        respondjs/respond.js
      )
    CODE
  end

  gsub_file 'app/assets/javascripts/application.js',
    '//= require turbolinks',
    '//# require turbolinks'

  create_file 'app/views/application/_header.html.erb'

  template 'config/locales/en.yml', force: true
  template 'config/locales/zh-TW.yml', force: true

  template 'app/views/layouts/barebone.html.erb',
    'app/views/layouts/application.html.erb',
    force: true

  message = <<-CODE.strip_heredoc
    adjust application layout

    apply html5shiv and respond
    turn off turbolink
  CODE

  git add: '-A'
  git commit: "-m '#{message}'"
end

def add_home_page
  ui.task __method__

  generate 'controller home index'
  gsub_file 'config/routes.rb', "get 'home/index'", "root 'home#index'"

  create_file 'app/views/home/index.html.erb', force: true
  remove_file 'spec/helpers/home_helper_spec.rb'
  remove_file 'spec/views/home'

  message = <<-CODE.strip_heredoc
    add home page
  CODE

  git add: '-A'
  git commit: "-m '#{message}'"
end

def apply_golden_theme
  ui.task __method__

  append_to_file 'Gemfile' do
    <<-CODE.strip_heredoc

      # Use compass-rails as css framework
      gem 'compass-rails'

      # Use jquery-ui-rails for jquery effects
      gem 'jquery-ui-rails', '< 5'

      # Use chosen-rails for form select
      gem 'chosen-rails'

      # Use will_paginate for pagination
      gem 'will_paginate'

      # Use golden-theme for theme helpers
      gem 'golden-theme'
    CODE
  end
  bundle_command "install #{bundle_option}"

  inject_into_file 'app/assets/javascripts/application.js',
    before: "//= require_tree .\n" do
    "//= require golden/theme/bootstrap\n"
  end

  inject_into_file 'app/assets/stylesheets/application.css',
    before: " *= require_tree .\n" do
    " *= require golden/theme/bootstrap\n"
  end

  append_to_file 'app/assets/stylesheets/bootstrap_custom.css.sass',
    <<-CODE.strip_heredoc

      .tabbable
        .nav-tabs
          margin-bottom: 20px

      .form-group
        label.boolean
          margin-right: 0.5em
    CODE

  inject_into_file 'app/controllers/application_controller.rb',
    after: "include CancanExt\n" do
    <<-CODE
  include Golden::Theme::Bootstrap::Pagination
  before_action do
    golden_theme_framework :bootstrap
  end
    CODE
  end

  inject_into_file 'app/models/user.rb',
    before: "end\n" do
    <<-CODE

  def name
    email
  end
    CODE
  end

  copy_file 'app/views/application/_header.html.erb', force: true

  copy_file 'app/views/application/_main_navigation.html.erb'

  inject_into_file 'app/views/layouts/application.html.erb',
    after: %Q{<div class="container">\n} do
    <<-CODE
    <aside role="flash_messages" class="row">
      <%= render 'application/bootstrap/flash_messages' %>
    </aside>

    CODE
  end

  inject_into_file 'config/locales/en.yml',
    after: %Q{title: '#{camelized}'\n} do
    <<-CODE
  application:
    header:
      nav_toggle: 'Toggle navigation'
      site_title: '#{camelized}'
    main_navigation:
      title: 'Main navigation'
    CODE
  end

  inject_into_file 'spec/support/helpers.rb',
    before: "end\n" do
    <<-CODE
  config.include Golden::Theme::CommonHelper, type: :view
  config.before :each, type: :view do
    controller.golden_theme_framework :bootstrap
  end
    CODE
  end

  message = <<-CODE.strip_heredoc
    apply golden-theme
  CODE

  git add: '-A'
  git commit: "-m '#{message}'"
end

def add_custom_devise_views
  ui.task __method__

  directory 'app/views/devise'
  copy_file 'config/locales/devise_custom.en.yml'
  copy_file 'config/locales/devise_custom.zh-TW.yml'

  message = <<-CODE.strip_heredoc
    apply custom devise views
  CODE

  git add: '-A'
  git commit: "-m '#{message}'"
end

def add_custom_generators
  ui.task __method__

  directory 'lib/rails/generators/erb/scaffold'
  directory 'lib/templates/erb/scaffold', force: true
  directory 'lib/templates/rails/responders_controller'
  copy_file 'config/initializers/generators.rb'

  message = <<-CODE.strip_heredoc
    apply custom generators
  CODE

  git add: '-A'
  git commit: "-m '#{message}'"
end

def apply_role_and_role_owner
  ui.task __method__

  generate 'scaffold role name description enabled:boolean'
  generate 'model role_owner role:belongs_to owner:belongs_to{polymorphic}'

  rake 'db:migrate'

  copy_file 'app/models/concerns/role_ownable.rb'

  inject_into_file 'app/models/role.rb',
    after: "class Role < ActiveRecord::Base\n" do
    <<-CODE
  has_many :role_owners
  has_many :users, through: :role_owners, source: :owner, source_type: 'User'

  validates :name, presence: true

  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }

  def human_name
    I18n.t(name, scope: 'roles.names')
  end
    CODE
  end

  inject_into_file 'app/models/user.rb',
    after: "class User < ActiveRecord::Base\n" do
    <<-CODE
  include RoleOwnable

    CODE
  end

  copy_file 'app/abilities/administrator_ability.rb'
  copy_file 'app/abilities/manager_ability.rb'
  inject_into_file 'app/models/ability.rb',
    before: "      abilities\n" do
    <<-CODE
      if user.has_role? 'administrator'
        abilities.merge AdministratorAbility.new
      end

      if user.has_role? 'manager'
        abilities.merge ManagerAbility.new
      end

    CODE
  end

  empty_directory 'lib/tasks/import'
  copy_file 'lib/tasks/utilities.rake'
  copy_file 'lib/tasks/import/roles.rake'
  copy_file 'lib/tasks/import/users.rake'

  empty_directory 'db/import'
  copy_file 'db/import/roles.yml'
  copy_file 'db/import/users.yml'

  append_to_file 'db/seeds.rb' do
    <<-CODE.strip_heredoc

      Rake::Task['import:roles'].execute
      Rake::Task['import:users'].execute
    CODE
  end

  gsub_file 'app/views/roles/_role.html.erb',
    'role.name',
    'role.human_name'

  gsub_file 'app/views/roles/_role.html.erb',
    'role.enabled',
    'yes_or_no role.enabled'

  gsub_file 'app/views/roles/_table.html.erb',
    'role.name',
    'role.human_name'

  gsub_file 'app/views/roles/_table.html.erb',
    'role.enabled',
    'yes_or_no role.enabled'

  copy_file 'config/locales/roles.en.yml', force: true
  copy_file 'config/locales/roles.zh-TW.yml', force: true

  copy_file 'spec/controllers/roles_controller_spec.rb', force: true
  copy_file 'spec/fabricators/role_fabricator.rb'
  copy_file 'spec/fabricators/user_fabricator.rb'
  copy_file 'spec/models/role_owner_spec.rb', force: true
  copy_file 'spec/models/role_spec.rb', force: true
  copy_file 'spec/models/user_spec.rb', force: true
  copy_file 'spec/requests/roles_spec.rb', force: true
  copy_file 'spec/routing/roles_routing_spec.rb', force: true
  directory 'spec/views/roles', force: true

  message = <<-CODE.strip_heredoc
    apply role and role_owner

    rails g scaffold role name description enabled:boolean
    rails g model role_owner role:belongs_to owner:belongs_to{polymorphic}
    rake db:migrate
  CODE

  git add: '-A'
  git commit: "-m '#{message}'"
end

def run_specs
  ui.task __method__

  bundle_command 'exec rake db:create db:migrate'
  bundle_command 'exec rake spec'
end

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
apply_shoulda_matchers
apply_pry
apply_awesome_print
apply_hirb
apply_better_errors
apply_rack_mini_profiler
apply_rails_best_practices
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
apply_powder
apply_role_and_role_owner
run_specs
