class MemberAbility
  include CanCan::Ability

  attr_accessor :current_user

  def initialize current_user, options = {}
    self.current_user = current_user
  end
end
