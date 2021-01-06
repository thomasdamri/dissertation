# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # User needs to be logged in first
    if user.present?

      # Admin has all permissions
      if user.admin
        can :manage, :all
      end

      # Staff can edit their own modules
      if user.staff
        can :read, UniModule
        can :manage, UniModule, staff_modules: {user_id: user.id}

        # Staff can edit their modules' teams
        can :manage, Team do |team|
          team.uni_module.staff_modules.pluck(:user_id).include? user.id
        end

        # Staff can manage their assessments if they are part of the module
        can :manage, Assessment do |assess|
          # If creating an assessment, uni_module will be blank
          if assess.uni_module.nil?
            # Further auth checks are done at the controller level
            true
          else
            assess.uni_module.staff_modules.pluck(:user_id).include? user.id
          end
        end
        cannot [:fill_in, :process_assess], Assessment

      else
        # Students can view their own team
        can :read, Team, student_teams: {user_id: user.id}
        # Students can fill in their team's peer assessments and see the results
        can [:fill_in, :process_assess, :results], Assessment do |assess|
          user.teams.pluck(:uni_module_id).include? assess.uni_module.id
        end
      end
    end
  end
end
