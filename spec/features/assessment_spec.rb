require 'rails_helper'

describe 'Creating an assessment' do
  specify 'I can create an assessment if I am part of the module'
  specify 'I cannot create an assessment if I am not part of the module, but still staff'
  specify 'I cannot create an assessment if I am staff'
end

describe 'Removing an assessment' do
  specify 'I can remove an assessment if I am part of the module'
  specify 'I cannot remove an assessment if I am not part of the module, but still staff'
  specify 'I cannot remove an assessment if I am a student'
end


describe 'Filling in an assessment' do
  specify 'I can fill in an assessment if I am a student who is on the module'
  specify 'I cannot fill in an assessment as a staff member on the module'
  specify 'I cannot fill in an assessment as a student on a different module'
  specify 'I can only fill in an assessment once'
  specify 'I cannot leave fields in the assessment blank and have it be valid'
end

describe 'Viewing assessment results' do
  specify 'I can view peer assessment results as a student only once the closing date has passed'
  specify "As a student I cannot see another student's results"
  specify 'As staff I can see individual student responses to the assessment'
end
