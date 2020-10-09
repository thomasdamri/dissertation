# == Schema Information
#
# Table name: criteria
#
#  id            :bigint           not null, primary key
#  title         :string(255)
#  order         :integer
#  response_type :string(255)
#  min_value     :float(24)
#  max_value     :float(24)
#  assessment_id :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Criterium < ApplicationRecord

  # Possible data types
  @@string = 0
  @@int = 1
  @@float = 2
  @@bool = 3

  # Accessors for the data types
  def self.string_type
    return @@string
  end

  def self.int_type
    return @@int
  end

  def self.float_type
    return @@float
  end

  def self.bool_type
    return @@bool
  end

  # Convert from the display string to a storable enum value
  def self.type_dict
    {"Text" => @@string,
     "Whole Number" => @@int,
     "Decimal Number" => @@float,
     "Boolean" => @@bool}
  end

  belongs_to :assessment
  has_many :assessment_results

  validates :title, presence: true
  # Order must be unique within the assessment
  validates :order, presence: true, uniqueness: {scope: :assessment_id}
  validates :response_type, presence: true

  validates_with CriteriumValidator

end
