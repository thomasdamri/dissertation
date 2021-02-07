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

      if user.staff
        # Staff can view and manage their own modules
        can :read, UniModule
        # Can create modules regardless of ownership (as no ownership has been set yet)
        can [:new, :create], UniModule
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

        # Can only interact with work logs if they are on a module the user is part of
        can [:review_worklogs, :display_worklogs, :display_log, :view_disputes, :override_form, :process_override, :process_uphold], Worklog do |wl|
          wl.uni_module.staff_modules.pluck(:user_id).include? user.id
        end

      else
        # Students can view their own team
        can :read, Team, student_teams: {user_id: user.id}
        # Students can fill in their team's peer assessments and see the results
        can [:fill_in, :process_assess, :results], Assessment do |assess|
          user.teams.pluck(:uni_module_id).include? assess.uni_module.id
        end

        can [:review_worklogs, :display_worklogs, :display_log, :accept_worklog, :dispute_worklog, :dispute_form, :new_worklog, :process_worklog], Worklog do |wl|
          user.teams.pluck(:uni_module_id).include? wl.uni_module.id
        end

      end
    end
  end
end
