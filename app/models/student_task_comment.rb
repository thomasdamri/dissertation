class StudentTaskComment < ApplicationRecord
  belongs_to :student_task, counter_cache: true
  belongs_to :user
  has_one_attached :image

  after_create_commit {self.updateLatestCommentDate()}

  def updateLatestCommentDate()
    self.student_task.latest_comment_time = DateTime.now
    self.student_task.save
  end

end
