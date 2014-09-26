class UserParameterSanitizer < Devise::ParameterSanitizer
  def sign_up
    default_params.permit(
      :email, :password, :password_confirmation
    )
  end
end
