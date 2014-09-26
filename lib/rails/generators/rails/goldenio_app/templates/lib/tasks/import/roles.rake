load 'tasks/utilities.rake'

namespace :import do
  desc 'Import roles, options: FILE=roles.yml'
  task roles: :environment do
    file_path = ENV['FILE'] || Rails.root.join('db', 'import', 'roles.yml')
    next unless File.exist? file_path

    import_yaml_file file_path do |attrs, imported|
      name = attrs.delete 'name'
      role_attrs = {
      }.merge attrs
      role = Role.create_with(role_attrs).find_or_create_by name: name

      next unless role.persisted?
      imported << role.name
    end
  end
end
