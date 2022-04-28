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

        can [:show_student_task, :comment, :like_task, :return_task_list], StudentTask do |st|
          st.student_team.team.uni_module.staff_modules.pluck(:user_id).include? user.id
        end

        can [:show_report, :report_resolution, :show_complete_report, :complete_report, :complete_report_form], StudentReport do |sr|
          sr.student_team.team.uni_module.staff_modules.pluck(:user_id).include? user.id
        end 

        can [:manage], StudentTeam do |st|
          st.team.uni_module.staff_modules.pluck(:user_id).include? user.id
        end

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

        # Staff can manage the peer assessment weightings for students on their modules
        can :manage, StudentWeighting do |sw|
          # Does the assessment's module involve the current user?
          sw.assessment.uni_module.staff_modules.pluck(:user_id).include? user.id
        end


      else
        # # Students can view their own home page
        can :manage, StudentTeam, user: user

        can :manage, StudentChat, user: user
      
        can :create, StudentTask

        # Can read any task created by a team member
        can [:show_student_task, :comment, :like_task], StudentTask do |st|
          st.student_team.team.student_teams.pluck(:user_id).include? user.id
        end

        can [:complete, :edit, :update, :destroy], StudentTask, user: user
        can [:delete_comment], StudentTaskComment, user: user

        # Must be apart of the team to create reports
        can [:create, :get_list, :create], StudentReport

        # Students can fill in their team's peer assessments and see the results
        can [:fill_in, :process_assess, :results], Assessment do |assess|
          user.teams.pluck(:uni_module_id).include? assess.uni_module.id
        end

        can [:edit, :destroy, :update], StudentTask do |st|
          user.student_teams.pluck(:id).include? st.student_team_id
        end

        can [:delete_comment], StudentTaskComment, user_id: user.id
      end
    end
  end
end
