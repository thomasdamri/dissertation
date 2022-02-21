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
        # Staff can view any module, as well as staff associated with it
        can [:read, :show_all_staff], UniModule
        # Can create modules regardless of ownership (as no ownership has been set yet)
        can [:new, :create], UniModule
        # Staff can only manage their own modules
        can :manage, UniModule, staff_modules: {user_id: user.id}

        # Staff can edit their modules' teams
        can :manage, Team do |team|
          team.uni_module.staff_modules.pluck(:user_id).include? user.id
        end
        # Staff cannot make work logs
        cannot [:new_worklog, :process_worklog], Team

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

        # Staff can manage the peer assessment weightings for students on their modules
        can :manage, StudentWeighting do |sw|
          # Does the assessment's module involve the current user?
          sw.assessment.uni_module.staff_modules.pluck(:user_id).include? user.id
        end

        # Can only interact with work logs if they are on a module the user is part of
        can [:view_disputes, :override_form, :process_override, :process_uphold], Worklog do |wl|
          wl.uni_module.staff_modules.pluck(:user_id).include? user.id
        end

      else
        # Students can view their own team
        can :read, Team, student_teams: {user_id: user.id}
        # Students can interact with their own team's worklogs
        can [:new_worklog, :process_worklog, :display_worklogs, :display_log, :review_worklogs], Team, student_teams: {user_id: user.id}
        # Students can fill in their team's peer assessments and see the results
        can [:fill_in, :process_assess, :results], Assessment do |assess|
          user.teams.pluck(:uni_module_id).include? assess.uni_module.id
        end

        # Can dispute worklogs from their own team
        can [:accept_worklog, :dispute_worklog, :dispute_form], Worklog do |wl|
          user.teams.pluck(:uni_module_id).include? wl.uni_module.id
        end

        can [:edit, :destroy, :update], StudentTask do |st|
          user.student_teams.pluck(:id).include? st.student_team_id
        end

        # can [:delete_comment], StudentTaskComment do |c|
        #   user.id == (c.user_id)
        # end
        can [:delete_comment], StudentTaskComment, user_id: user.id
      end
    end
  end
end
