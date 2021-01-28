# == Schema Information
#
# Table name: worklogs
#
#  id         :bigint           not null, primary key
#  author_id  :bigint
#  fill_date  :date
#  content    :text(65535)
#  override   :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Worklog < ApplicationRecord
  # One user wrote the worklog about one module
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :uni_module

  has_many :worklog_responses

  # Returns true if the worklog has been overridden.
  # The override attribute is blank unless a staff member has overriden the worklog contents
  def has_been_overridden?
    !override.nil?
  end

  # A worklog must have a date, an author, and a module
  validates :fill_date, presence: true
  validates :author_id, presence: true
  validates :uni_module_id, presence: true

end
