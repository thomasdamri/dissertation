class Question < ApplicationRecord

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

  def self.max_title_length
    return 250
  end


  # If integer or float, this text displays the min/max values to the user
  def subtitle
    if response_type.to_i == @@int or response_type.to_i == @@float
      whole = ""
      min = min_value
      max = max_value
      # Include 'whole' in first part, if needs a whole number
      if response_type.to_i == @@int
        whole = "whole "
        min = min.to_i
        max = max.to_i
      end
      first_part = "Enter a #{whole}number"

      # Second part deals with minimum and maximum values

      # If neither a min or max, just return the first part now
      if min_value.nil? and max_value.nil?
        first_part
      elsif max_value.nil?
        "#{first_part} which is #{min} or more"
      elsif min_value.nil?
        "#{first_part} which is #{max} or less"
      else
        "#{first_part} between #{min} and #{max}"
      end

    end
  end

  belongs_to :assessment
  has_many :assessment_results, dependent: :destroy

  # Must have a title
  validates :title, presence: true, length: { maximum: self.max_title_length }
  # Response type must exist and must be within range
  validates :response_type, presence: true, inclusion: @@string..@@bool

  # Single and assessed cannot be nil
  validates :single, inclusion: {in: [true, false]}
  validates :assessed, inclusion: {in: [true, false]}

  # Additional validations involving min + max values
  validates_with QuestionValidator

end
