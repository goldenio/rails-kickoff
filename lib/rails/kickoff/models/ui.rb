module Rails
  module Kickoff
    class UI
      include Thor::Shell

      def initialize
      end

      def task message, ansi_color = :blue
        say_status :task, set_color(message, :bold), ansi_color
      end

      def note message, ansi_color = :magenta
        say_status :note, set_color(message, :bold), ansi_color
      end

      def fine message, ansi_color = :green
        say_status :success, set_color(message), ansi_color
      end

      def warn message, ansi_color = :yellow
        say_status :warn, set_color(message), ansi_color
      end

      def fail message, ansi_color = :red
        say_status :error, set_color(message), ansi_color
      end

      def info message, ansi_color = :white
        say_status :info, set_color(message), ansi_color
      end
    end
  end
end
