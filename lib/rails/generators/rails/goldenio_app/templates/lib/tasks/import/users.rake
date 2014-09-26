load 'tasks/utilities.rake'

namespace :import do
  desc 'Import users, options: FILE=users.yml'
  task users: :environment do
    file_path = ENV['FILE'] || Rails.root.join('db', 'import', 'users.yml')
    next unless File.exist? file_path

    import_yaml_file file_path do |attrs, imported|
      role_names = attrs.delete 'roles'
      roles = Role.where(name: role_names).all

      user_email = attrs.delete 'email'
      user_skip_confirmation = attrs.delete 'skip_confirmation'
      user_attrs = {
        password: user_email
      }.merge attrs
      user = User.create_with(user_attrs).find_or_initialize_by email: user_email
      user.skip_confirmation! if user_skip_confirmation
      user.save

      next unless user.persisted?
      user.roles = roles
      user.save # validate: false
      imported << user.email
    end

    print_info 'User related counts' do
      puts "User.count: #{User.count}"
      puts "RoleOwner.count: #{RoleOwner.count}"
    end
  end
end
