module Recipes
  module Authentication

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

  end
end
