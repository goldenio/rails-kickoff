class AdministratorAbility
  include CanCan::Ability

  def initialize
    can :manage, Role
  end
end
