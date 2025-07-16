class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= AdminUser.new

    case user.role


    when "admin"
      can :manage, ActiveAdmin::Page, name: "Dashboard", namespace_name: "admin"
      can :manage, :all
    end
  end
end
