module Recipes
  module Assets

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

  end
end
