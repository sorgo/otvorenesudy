class Decree < ActiveRecord::Base
  include Resource::Storage
  
  attr_accessible :uri,
                  :case_number,
                  :file_number,
                  :date,
                  :ecli,
                  :text
  
  belongs_to :proceeding
  
  belongs_to :court
  
  has_many :judgements, dependent: :destroy
  
  has_many :judges, through: :judgements
  
  belongs_to :form,   class_name: :DecreeForm,   foreign_key: :decree_form_id
  belongs_to :nature, class_name: :DecreeNature, foreign_key: :decree_nature_id
  
  belongs_to :legislation_area
  belongs_to :legislation_subarea
  
  has_many :legislation_usages
  
  has_many :legislations, through: :legislation_usages

  storage :page,     JusticeGovSk::Storage::DecreePage,     extension: :html
  storage :document, JusticeGovSk::Storage::DecreeDocument, extension: :pdf
end
