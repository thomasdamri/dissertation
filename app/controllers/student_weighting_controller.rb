class StudentWeightingController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  # AJAX modal for showing the form to override students' grades
  def update_grade_form
    @ind_weight = StudentWeighting.find(params['id'])

    respond_to do |format|
      format.js { render layout: false }
    end
  end

  # POST url for processing the grade update form
  def process_grade_update
    @ind_weight = StudentWeighting.find(params['id'])
    weight = params['new_weight'].to_f
    reason = params['reason']

    # Check for a ridiculous value
    if weight < 0 or weight > 10
      redirect_to view_ind_grades_path(@ind_weight.assessment), notice: "Invalid weight given"
      return
    end

    # Check to see if a reason was given
    if reason.nil? or reason == ""
      redirect_to view_ind_grades_path(@ind_weight.assessment), notice: "No reason was given"
      return
    end

    # If params are valid, update the student's weighting
    @ind_weight.manual_update(weight, reason)
    redirect_to view_ind_grades_path(@ind_weight.assessment), notice: "Weighting updated successfully"
  end

  # POST url for resetting a manually set grade
  def reset_grade
    stud_weight = StudentWeighting.find(params['id'])
    # Make manual_set false + remove the reason
    stud_weight.manual_set = false
    stud_weight.reason = nil
    stud_weight.save
    # Re-generate the student's weighting from assessment responses
    assess = stud_weight.assessment
    team = stud_weight.user.teams.where(uni_module: assess.uni_module).first
    assess.generate_weightings(team)

    redirect_to view_ind_grades_path(stud_weight.assessment), notice: "Weighting reset successfully"
  end
end