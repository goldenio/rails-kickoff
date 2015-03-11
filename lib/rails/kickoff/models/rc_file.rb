require 'rails/kickoff/models/ui'

module Rails
  module Kickoff
    class RcFile
      def initialize file = '~/.railskickoffrc', argv = {}
        @default_file = File.expand_path file
        @argv = argv
        @ui = UI.new
      end

      def argv
        if File.exist? @default_file
          File.readlines(@default_file).flat_map(&:strip).each do |setting|
            next if setting =~ /\A#/
            key, value = setting.split('=')
            @argv[key] = value
          end
          @ui.info "Using values from #{@default_file}:"
          @argv.each { |key, value| @ui.info "#{key}: #{value}" }
          @argv
        else
          @ui.fail "The #{@default_file} cannot be found."
        end
      end
    end
  end
end
