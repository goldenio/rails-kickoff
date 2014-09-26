module CancanExt
  extend ActiveSupport::Concern
  included do
    rescue_from ::CanCan::AccessDenied do |exception|
      redirect_to main_app.root_url, alert: exception.message
    end
  end

  module ClassMethods
  end

  protected

  def current_ability
    @current_ability ||= Ability.ability_for current_user
  end
end
