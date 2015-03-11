module Recipes
  module Server

    def apply_foreman
      ui.task __method__

      append_to_file 'Gemfile' do
        <<-CODE.strip_heredoc

          # Use foreman to start development server
          gem 'foreman', require: false, group: :development
        CODE
      end
      bundle_command "install #{bundle_option}"

      copy_file 'Procfile'

      message = <<-CODE.strip_heredoc
        apply foreman
      CODE

      git add: '-A'
      git commit: "-m '#{message}'"
    end

    def apply_powder
      ui.task __method__

      append_to_file 'Gemfile' do
        <<-CODE.strip_heredoc

          # Use powder to start development server
          gem 'powder', require: false, group: :development
        CODE
      end
      bundle_command "install #{bundle_option}"

      message = <<-CODE.strip_heredoc
        apply powder
      CODE

      git add: '-A'
      git commit: "-m '#{message}'"
    end

  end
end
