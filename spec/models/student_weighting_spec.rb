# == Schema Information
#
# Table name: student_weightings
#
#  id                    :bigint           not null, primary key
#  user_id               :bigint
#  assessment_id         :bigint
#  weighting             :float(24)
#  results_at_last_check :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  manual_set            :boolean          default(FALSE)
#  reason                :string(255)
#
require 'rails_helper'

RSpec.describe StudentWeighting, type: :model do
  it 'is valid with valid attributes' do
    u1 = create :user
    u = create :uni_module
    t = create :team , uni_module: u
    st = create :student_team, user: u1, team: t
    a = create :assessment, uni_module: u
    sw = build(:student_weighting, student_team: st, assessment: a)
    expect(sw).to be_valid
  end

  it 'is invalid with blank attributes' do
    sw = build :blank_student_weighting
    expect(sw).to_not be_valid
  end

  it 'requires a reason when the weighting is manually set' do
    u1 = create :user
    u = create :uni_module
    t = create :team , uni_module: u
    st = create :student_team, user: u1, team: t
    a = create :assessment, uni_module: u
    sw = build :student_weighting, student_team: st, assessment: a

    sw.reason = nil
    sw.manual_set = true
    expect(sw).to_not be_valid

    sw.reason = "Something"
    expect(sw).to be_valid
  end

  describe '#update_weightings' do
    it 'only updates weightings when manual_set is false' do
      u1 = create :user
      u = create :uni_module
      t = create :team , uni_module: u
      st = create :student_team, user: u1, team: t
      a = create :assessment, uni_module: u
      sw = create(:student_weighting, student_team: st, assessment: a)

      # By default, weighting is 1 and results_at_last_check is 0
      sw.manual_set = true
      sw.update_weighting(2, 2)
      expect(sw.weighting).to_not eq 2
      expect(sw.results_at_last_check).to_not eq 2

      sw.manual_set = false
      sw.update_weighting(2, 2)
      expect(sw.weighting).to eq 2
      expect(sw.results_at_last_check).to eq 2
    end
  end

  describe '#manual_update' do
    it 'updates the weighting to a set the values of weighting, and reason' do
      u1 = create :user
      u = create :uni_module
      t = create :team , uni_module: u
      st = create :student_team, user: u1, team: t
      a = create :assessment, uni_module: u
      sw = create(:student_weighting, student_team: st, assessment: a)

      sw.manual_update(1.5, "Something")
      expect(sw.weighting).to eq 1.5
      expect(sw.reason).to eq "Something"
      expect(sw.manual_set).to eq true
    end
  end

end
