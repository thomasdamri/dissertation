# == Schema Information
#
# Table name: worklogs
#
#  id            :bigint           not null, primary key
#  author_id     :bigint
#  fill_date     :date
#  content       :text(65535)
#  override      :text(65535)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  uni_module_id :bigint
#
class Worklog < ApplicationRecord

  def self.max_content_length
    return 280
  end

  # One user wrote the worklog about one module
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :uni_module

  has_many :worklog_responses, dependent: :destroy

  # Returns true if the worklog has been overridden.
  # The override attribute is blank unless a staff member has overriden the worklog contents
  def is_overridden?
    !override.nil?
  end

  # Ensures fill_date is a monday, so it marks the beginning of the week where log was filled in
  def ensure_mondays
    unless self.fill_date.nil?
      # Don't set it to previous monday if already a monday
      unless self.fill_date.monday?
        self.fill_date = self.fill_date.prev_occurring(:monday)
      end
      save
    end
  end

  # A worklog must have a date, an author, and a module
  # A user cant submit a worklog for the same date and module
  validates :fill_date, presence: true, uniqueness: { scope: [:author_id, :uni_module_id] }
  validates :author_id, presence: true
  validates :uni_module_id, presence: true
  # Content must be within 280 characters to prevent students writing too much
  validates :content, presence: true, length: { maximum: self.max_content_length }

end
