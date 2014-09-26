Rails.application.config.action_mailer.delivery_method = :sendmail
Rails.application.config.action_mailer.sendmail_settings = {
  location: '/usr/sbin/exim4',
  arguments: '-i'
}

Rails.application.config.action_mailer.default_url_options = {
  protocol: 'https',
  host: '<%= host_url %>'
}

Rails.application.config.action_mailer.default_options = {
  # bcc: ''
  from: '<%= mailer_sender %>'
}

Devise.setup do |config|
  config.mailer_sender = '<%= mailer_sender %>'
end
