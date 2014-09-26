module Ability
  class << self
    def ability_for user, options = {}
      abilities = AnonymousAbility.new

      return abilities unless user

      abilities.merge MemberAbility.new user, options

      abilities
    end
    alias_method :new, :ability_for
  end
end
