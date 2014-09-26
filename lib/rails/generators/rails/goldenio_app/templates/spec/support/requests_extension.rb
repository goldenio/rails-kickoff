module RequestsExtension
  def follow_sign_in_request
    expect(response.status).to eq 302
    expect(response).to redirect_to user_session_path

    follow_redirect!
    expect(response).to render_template 'devise/sessions/new'

    post user_session_path, user: { email: user.email, password: user.password }

    follow_redirect!
    expect(response.body).to include I18n.t('devise.sessions.signed_in')
  end
end

RSpec.configure do |config|
  config.include RequestsExtension, type: :request
end
