module Recipes
  module Common

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
    config.i18n.default_locale = #{default_locale || :en}
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

    def create_develop_branch
      git checkout: '-b develop'
    end

  end
end
