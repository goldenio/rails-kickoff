module Rails
  module Kickoff
    module Helper

      def ui
        @ui ||= Rails::Kickoff::UI.new
      end

      def git_config field
        command = "git config --global #{field}"
        config = run(command, capture: true).strip
        config.empty? ? "YOUR_#{field.upcase}".sub('.', '_') : config
      end

      def add_source_paths path
        @source_paths.unshift path
      end

      def read_rc_file file
        @argv ||= Rails::Kickoff::RcFile.new(file).argv
      end

      def mailer_sender
        @argv['MAILER_SENDER']
      end

      def host_url
        "#{app_name}.#{@argv['DOMAIN_URL']}"
      end

      def bundle_option
        @argv['BUNDLE_OPTION'] || nil
      end

      def default_locale
        @argv['DEFAULT_LOCALE'] || ':en'
      end

      def templates_path name
        relative_path = "../../generators/rails/#{name}/templates"
        File.expand_path relative_path, __FILE__
      end

    end
  end
end
