class StudentTaskComment < ApplicationRecord
  belongs_to :student_task, counter_cache: true
  belongs_to :user
  has_one_attached :image

  # After comment creation, update the tasks latest comment date
  after_create_commit {self.updateLatestCommentDate()}

  validates :comment, length: { in: 1..300}

  # Sets the latest comment time to now
  def updateLatestCommentDate()
    self.student_task.latest_comment_time = DateTime.now
    self.student_task.save
  end

end
