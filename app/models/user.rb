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

  # Can be part of multiple teams, teams have multiple students
  has_and_belongs_to_many :teams
  # Can manage many modules
  has_and_belongs_to_many :uni_modules
  # Has many AssessmentResults written by the user
  has_many :author_results, class_name: 'AssessmentResult', foreign_key: 'author_id'
  # Has many AssessmentResults written about the user
  has_many :target_results, class_name: 'AssessmentResult', foreign_key: 'target_id'

  validates :staff, inclusion: {in: [true, false]}
  validates :admin, inclusion: {in: [true, false]}

  validates_with UserValidator

  end
