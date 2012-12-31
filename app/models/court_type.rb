# encoding: utf-8

class CourtType < ActiveRecord::Base
  include Type::Enumerable
  
  attr_accessible :value
  
  has_many :courts, dependent: :destroy
  
  validates :value, presence: true
  
  value :constitutional, 'Ústavný'
  value :highest,        'Najvyšší'
  value :specialized,    'Špecializovaný'
  value :regional,       'Krajský'
  value :district,       'Okresný'
end
