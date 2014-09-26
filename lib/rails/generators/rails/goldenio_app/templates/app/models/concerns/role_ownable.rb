module RoleOwnable
  extend ActiveSupport::Concern
  included do
    has_many :role_owners, as: :owner, dependent: :destroy
    has_many :roles, through: :role_owners

    # after_create :ensure_role
  end

  module ClassMethods
  end

  def has_role? role_name
    roles.map(&:name).include? role_name.to_s
  end

  def has_any_role? role_names
    role_names.any? { |role_name| self.has_role? role_name }
  end

  def role_names
    roles.map(&:human_name).join(', ')
  end

  private

  def ensure_role
    return unless roles.count < 1
    member = ::Role.where(name: 'member').first
    self.roles << member if member
  end
end
