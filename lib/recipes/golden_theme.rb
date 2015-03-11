module Recipes
  module GoldenTheme

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

  end
end
