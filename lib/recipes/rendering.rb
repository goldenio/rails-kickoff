module Recipes
  module Rendering

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

    def apply_slim
      ui.task __method__

      append_to_file 'Gemfile' do
        <<-CODE.strip_heredoc

          # Use slim-rails as view engine
          gem 'slim-rails'
        CODE
      end
      bundle_command "install #{bundle_option}"

      directory 'lib/rails/generators/slim/scaffold'
      directory 'lib/templates/slim/scaffold', force: true

      message = <<-CODE.strip_heredoc
        apply slim-rails
      CODE

      git add: '-A'
      git commit: "-m '#{message}'"
    end

  end
end
