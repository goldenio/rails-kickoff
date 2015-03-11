module Recipes
  module Form

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

  end
end
