class StudentReport < ApplicationRecord

  belongs_to :student_team
  has_one :user, through: :student_team
  has_many :report_objects,  dependent: :destroy

  # A student report can link to many report objects
  accepts_nested_attributes_for :report_objects, allow_destroy: true

  validates :report_reason, length: { in: 5..1000}

  # Converts the integer report type value to the string value
  def reporting_int_to_string
    case object_type
    when 0
      return "User"
    when 1
      return "Grade"
    else
      return "Task"
    end
  end

end
