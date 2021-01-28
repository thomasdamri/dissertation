# == Schema Information
#
# Table name: worklog_responses
#
#  id         :bigint           not null, primary key
#  worklog_id :bigint
#  user_id    :bigint
#  status     :integer
#  reason     :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class WorklogResponse < ApplicationRecord
  # Possible statuses
  @@accept = 0
  @@reject = 1
  @@resolved = 2

  def self.accept_status
    return @@accept
  end

  def self.reject_status
    return @@reject
  end

  def self.resolved_status
    return @@resolved
  end

  def self.status_dict
    {"Accept": @@accept,
     "Reject": @@reject,
     "Resolved": @@resolved
    }
  end

  # One user responded to one worklog
  belongs_to :worklog
  belongs_to :user

  # A response must have a status, an associated worklog, and a user
  # Each user can respond to a worklog only once
  validates :status, presence: true
  validates :worklog_id, presence: true, uniqueness: {scope: :user}
  validates :user_id, presence: true
end
