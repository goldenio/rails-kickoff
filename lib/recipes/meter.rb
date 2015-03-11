module Recipes
  module Meter

    def apply_rack_mini_profiler
      ui.task __method__

      append_to_file 'Gemfile' do
        <<-CODE.strip_heredoc

          # Use rack-mini-profiler for performance
          gem 'rack-mini-profiler', group: :development
          gem 'bullet', group: :development
        CODE
      end
      bundle_command "install #{bundle_option}"

      message = <<-CODE.strip_heredoc
        apply rack-mini-profiler
      CODE

      git add: '-A'
      git commit: "-m '#{message}'"
    end

    def apply_rails_best_practices
      ui.task __method__

      append_to_file 'Gemfile' do
        <<-CODE.strip_heredoc

          # Use rails_best_practices for code metric tool
          gem 'rails_best_practices', require: false, group: :development
        CODE
      end
      bundle_command "install #{bundle_option}"

      message = <<-CODE.strip_heredoc
        apply rails_best_practices
      CODE

      git add: '-A'
      git commit: "-m '#{message}'"
    end

  end
end
