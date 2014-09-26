require 'rails/generators/erb'
require 'rails/generators/resource_helpers'

module Erb
  module Generators
    class ScaffoldGenerator < Base
      include Rails::Generators::ResourceHelpers

      argument :attributes, type: :array, default: [], banner: 'field:type field:type'

      def create_root_folder
        empty_directory File.join('app/views', controller_file_path)
      end

      def copy_view_files
        available_views.each do |view|
          filename = filename_with_extensions(view)
          case view
          when '_section'
            targetname = filename.sub('section', controller_file_path.singularize)
          else
            targetname = filename
          end
          template filename, File.join('app/views', controller_file_path, targetname)
        end
      end

      def copy_locale_files
        template 'en.yml.erb', "config/locales/#{controller_file_path}.en.yml"
        template 'zh-TW.yml.erb', "config/locales/#{controller_file_path}.zh-TW.yml"
      end

      protected

      def available_views
        %w(index edit show new _form _table _section)
      end
    end
  end
end
