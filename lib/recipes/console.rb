module Recipes
  module Console

    def apply_pry
      ui.task __method__

      append_to_file 'Gemfile' do
        <<-CODE.strip_heredoc

          # Use pry for console
          gem 'pry-rails'
          gem 'pry-byebug', group: :development
          gem 'pry-stack_explorer', group: :development
          gem 'pry-remote', group: :development
        CODE
      end
      bundle_command "install #{bundle_option}"

      create_file '.pryrc'

      copy_file 'config/initializers/pry.rb'

      message = <<-CODE.strip_heredoc
        apply pry
      CODE

      git add: '-A'
      git commit: "-m '#{message}'"
    end

    def apply_awesome_print
      ui.task __method__

      append_to_file 'Gemfile' do
        <<-CODE.strip_heredoc

          # Use awesome_print for console
          gem 'awesome_print', require: false
        CODE
      end
      bundle_command "install #{bundle_option}"

      append_to_file '.pryrc' do
        <<-CODE.strip_heredoc
          require 'awesome_print'
          AwesomePrint.pry!
        CODE
      end

      message = <<-CODE.strip_heredoc
        apply awesome_print
      CODE

      git add: '-A'
      git commit: "-m '#{message}'"
    end

    def apply_hirb
      ui.task __method__

      append_to_file 'Gemfile' do
        <<-CODE.strip_heredoc

          # Use hirb for console
          gem 'hirb', require: false, group: :development
          gem 'hirb-unicode', require: false, group: :development
        CODE
      end
      bundle_command "install #{bundle_option}"

      append_to_file '.pryrc' do
        <<-CODE.strip_heredoc
          begin
            require 'hirb'
            require 'hirb-unicode'
            extend Hirb::Console
          rescue LoadError => e
          end
        CODE
      end

      message = <<-CODE.strip_heredoc
        apply hirb
      CODE

      git add: '-A'
      git commit: "-m '#{message}'"
    end

    def apply_better_errors
      ui.task __method__

      append_to_file 'Gemfile' do
        <<-CODE.strip_heredoc

          # Use better_errors for console
          gem 'better_errors', group: :development
        CODE
      end
      bundle_command "install #{bundle_option}"

      message = <<-CODE.strip_heredoc
        apply better_errors
      CODE

      git add: '-A'
      git commit: "-m '#{message}'"
    end

  end
end
