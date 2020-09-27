class User < ApplicationRecord
  include EpiCas::DeviseHelper
  
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  end
