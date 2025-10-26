class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= AdminUser.new
    Rails.logger.debug "Current user role: #{user.role.inspect}"

    role = user.role.to_s.downcase

    # Allow everyone logged into ActiveAdmin to access the Dashboard page
    can :read, ActiveAdmin::Page, name: "Dashboard", namespace_name: "admin"

    case role
    when "admin"
      can :manage, ActiveAdmin::Page, name: "Dashboard", namespace_name: "admin"
      can :manage, :all
    when "author"
      can :read, :all
      can [:create, :update], [
        News,
        Publication,
        Event,
        Project,
        PerformanceReport,
        AboutUs,
        RoadResearchCenter
      ]
      cannot :destroy, :all
      cannot :manage, AdminUser
    when "publisher"
      can :read, :all
      can [:create, :update, :destroy], [
        News,
        Publication,
        Event
      ]
      cannot :manage, AdminUser
    when "hr"
      can :read, :all
      can :manage, [
        Applicant,
        Vacancy
      ]
      cannot :manage, AdminUser
    when "purchaser"
      can :read, :all
      can :manage, [
        Bid,
        RoadAsset
      ]
      cannot :manage, AdminUser
    else
      can :read, :all
    end
  end
end

