# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  email              :string(255)      default(""), not null
#  sign_in_count      :integer          default(0), not null
#  current_sign_in_at :datetime
#  last_sign_in_at    :datetime
#  current_sign_in_ip :string(255)
#  last_sign_in_ip    :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  username           :string(255)
#  uid                :string(255)
#  mail               :string(255)
#  ou                 :string(255)
#  dn                 :string(255)
#  sn                 :string(255)
#  givenname          :string(255)
#  display_name       :string(255)
#  reg_no             :integer
#  staff              :boolean
#  admin              :boolean
#
class User < ApplicationRecord
  include EpiCas::DeviseHelper

  def self.max_display_name_length
    return 250
  end

  # Can be part of multiple teams, teams have multiple students
  has_many :student_teams, dependent: :destroy
  #has_many :teams, through: :student_teams
  # Can manage many modules
  has_many :staff_modules, dependent: :destroy
  has_many :uni_modules, through: :staff_modules
  # Has many AssessmentResults written by the user
  #has_many :author_results, foreign_key: 'author_id', class_name: 'AssessmentResult', dependent: :destroy
  # Has many AssessmentResults written about the user
  #has_many :target_results, foreign_key: 'target_id', class_name: 'AssessmentResult', dependent: :destroy
  # Has many weighting results (one per completed assessment)
  #has_many :student_weightings, dependent: :destroy

  # Each user will write many worklogs
  has_many :worklogs, foreign_key: 'author_id', class_name: 'Worklog'
  # Each user will respond to many worklogs
  has_many :worklog_responses

  # Must have a username and email. Staff and admin booleans cannot be nil
  validates :username, presence: true, uniqueness: true
  #validates :email, presence: true, uniqueness: true, case_sensitive: true
  validates :staff, inclusion: {in: [true, false]}
  validates :admin, inclusion: {in: [true, false]}

  validates_with UserValidator

  # Either displays the name for the student, or the one they set
  def real_display_name
    if (display_name.nil? or display_name.empty?) and (givenname.nil? or givenname.empty?) and (sn.nil? or sn.empty?)
      return "Name not found"
    end
    if (display_name.nil? or display_name.empty?)
      givenname + " " + sn
    else
      display_name
    end
  end

  # Mailto link for the email address
  def email_link
    "mailto:" + email
  end

  # Returns true if the user has already filled in the worklog for this module this week
  def has_filled_in_log?(uni_module)
    last_mon = Date.today.monday? ? Date.today : Date.today.prev_occurring(:monday)
    if Worklog.where(uni_module: uni_module, author: self, fill_date: last_mon).first.nil?
      false
    else
      true
    end
  end

end
