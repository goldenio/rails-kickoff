module DeviseExt
  extend ActiveSupport::Concern
  included do
  end

  module ClassMethods
  end

  protected

  def devise_parameter_sanitizer
    case resource_class.to_s
    when 'User'
      UserParameterSanitizer.new User, :user, params
    else
      super
    end
  end
end
