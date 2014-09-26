# default prompt_name is 'pry'. following line change it to project name
Pry.config.prompt_name = Rails.application.class.parent_name.underscore.dasherize

unless Rails.env.development?
  old_prompt = Pry.config.prompt

  # Show red environment name for production and yellow for all other non-development environments
  # \001 and \002 is the walkaround for readline bug according to https://github.com/pry/pry/issues/493
  if Rails.env.production?
    env = "\001\e[0;31m\002#{Rails.env.upcase}\001\e[0m\002" # red
  else
    env = "\001\e[0;33m\002#{Rails.env.upcase}\001\e[0m\002" # yellow
  end

  # https://github.com/pry/pry/wiki/Customization-and-configuration#Config_prompt
  Pry.config.prompt = [
    proc { |*a| "#{env} #{old_prompt.first.call(*a)}"  },
    proc { |*a| "#{env} #{old_prompt.second.call(*a)}" }
  ]
end
