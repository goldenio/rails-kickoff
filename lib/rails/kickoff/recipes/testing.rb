module Rails
  module Kickoff
    module Recipes
      module Testing

        def apply_rspec
          ui.task __method__

          append_to_file 'Gemfile' do
            <<-CODE.strip_heredoc

              # Use rspec-rails for testing
              gem 'rspec-rails', group: [:development, :test]
            CODE
          end
          bundle_command "install #{bundle_option}"

          generate 'rspec:install'

          # bundle_command 'exec binstubs rspec-core'

          uncomment_lines 'spec/rails_helper.rb', 'require f'
          empty_directory 'spec/support'
          # copy_file 'spec/support/action_dispatch.rb' # rails 4.1
          copy_file 'spec/support/helpers.rb'

          message = <<-CODE.strip_heredoc
            apply rspec

            rails g rspec:install
          CODE

          git add: '-A'
          git commit: "-m '#{message}'"
        end

        def apply_database_cleaner
          ui.task __method__

          append_to_file 'Gemfile' do
            <<-CODE.strip_heredoc

              # Use database_cleaner for testing
              gem 'database_cleaner', group: :test
            CODE
          end
          bundle_command "install #{bundle_option}"

          copy_file 'spec/support/database_cleaner.rb'

          message = <<-CODE.strip_heredoc
            apply database_cleaner
          CODE

          git add: '-A'
          git commit: "-m '#{message}'"
        end

        def apply_capybara
          ui.task __method__

          append_to_file 'Gemfile' do
            <<-CODE.strip_heredoc

              # Use capybara for testing
              gem 'capybara', group: :test
            CODE
          end
          bundle_command "install #{bundle_option}"

          inject_into_file 'spec/rails_helper.rb',
            after: "# Add additional requires below this line. Rails is not loaded until this point!\n" do
            "require 'capybara/rspec'\n"
          end

          message = <<-CODE.strip_heredoc
            apply capybara
          CODE

          git add: '-A'
          git commit: "-m '#{message}'"
        end

        def apply_fabrication
          ui.task __method__

          append_to_file 'Gemfile' do
            <<-CODE.strip_heredoc

              # Use fabrication for testing
              gem 'fabrication', group: [:development, :test]
            CODE
          end
          bundle_command "install #{bundle_option}"

          empty_directory 'spec/fabricators'

          message = <<-CODE.strip_heredoc
            apply fabrication
          CODE

          git add: '-A'
          git commit: "-m '#{message}'"
        end

        def apply_faker
          ui.task __method__

          append_to_file 'Gemfile' do
            <<-CODE.strip_heredoc

              # Use faker for testing
              gem 'faker', group: [:development, :test]
            CODE
          end
          bundle_command "install #{bundle_option}"

          message = <<-CODE.strip_heredoc
            apply faker
          CODE

          git add: '-A'
          git commit: "-m '#{message}'"
        end

        def apply_simplecov
          ui.task __method__

          append_to_file 'Gemfile' do
            <<-CODE.strip_heredoc

              # Use simplecov for code metric tool
              gem 'simplecov', require: false, group: :test
            CODE
          end
          bundle_command "install #{bundle_option}"

          inject_into_file 'spec/spec_helper.rb',
            before: "RSpec.configure do |config|\n" do
            <<-CODE.strip_heredoc

              require 'simplecov'

            CODE
          end

          copy_file '.simplecov'

          append_to_file '.gitignore' do
            <<-CODE.strip_heredoc

              # Ignore all testing files
              /coverage
            CODE
          end

          message = <<-CODE.strip_heredoc
            apply simplecov
          CODE

          git add: '-A'
          git commit: "-m '#{message}'"
        end

        def apply_shoulda_matchers
          ui.task __method__

          append_to_file 'Gemfile' do
            <<-CODE.strip_heredoc

              # Use shoulda-matchers for testing
              gem 'shoulda-matchers', require: false, group: :test
            CODE
          end
          bundle_command "install #{bundle_option}"

          inject_into_file 'spec/rails_helper.rb',
            after: "# Add additional requires below this line. Rails is not loaded until this point!\n" do
            "require 'shoulda/matchers'\n"
          end

          message = <<-CODE.strip_heredoc
            apply shoulda-matchers
          CODE

          git add: '-A'
          git commit: "-m '#{message}'"
        end

      end
    end
  end
end
