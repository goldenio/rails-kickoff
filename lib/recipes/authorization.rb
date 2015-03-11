module Recipes
  module Authorization

    def apply_cancancan
      ui.task __method__

      append_to_file 'Gemfile' do
        <<-CODE.strip_heredoc

          # Use cancancan for authorization
          gem 'cancancan'
        CODE
      end
      bundle_command "install #{bundle_option}"

      copy_file 'app/controllers/concerns/cancan_ext.rb'

      inject_into_file 'app/controllers/application_controller.rb',
        after: "include DeviseExt\n" do
        "  include CancanExt\n"
      end

      copy_file 'app/models/ability.rb'

      inject_into_file 'config/application.rb',
        before: "  end\n" do
        <<-CODE

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(
      #\{config.root\}/app/abilities
    )
        CODE
      end

      copy_file 'app/abilities/anonymous_ability.rb'
      copy_file 'app/abilities/member_ability.rb'

      copy_file 'config/locales/1-gems/cancancan.zh-TW.yml'

      inject_into_file 'spec/rails_helper.rb',
        after: "# Add additional requires below this line. Rails is not loaded until this point!\n" do
        "require 'cancan/matchers'\n"
      end

      message = <<-CODE.strip_heredoc
        apply cancancan
      CODE

      git add: '-A'
      git commit: "-m '#{message}'"
    end

  end
end
