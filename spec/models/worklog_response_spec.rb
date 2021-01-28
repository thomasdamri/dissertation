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
require 'rails_helper'

RSpec.describe WorklogResponse, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
