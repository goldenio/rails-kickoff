module Rails
  module Kickoff
    class Git
      include Thor::Shell
      include Thor::Action

      def initialize
      end

      def config field
        command = "git config --global #{field}"
        config = run(command, capture: true).strip
        config.empty? ? "YOUR_#{field.upcase}".sub('.', '_') : config
      end
    end
  end
end
