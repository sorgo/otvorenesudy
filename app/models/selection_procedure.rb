class SelectionProcedure < ActiveRecord::Base
  include Probe
  include Resource::URI

  attr_accessible :organization_name,
                  :organization_name_unprocessed,
                  :organization_description,
                  :date,
                  :description,
                  :place,
                  :position,
                  :state,
                  :workplace,
                  :closed_at

  belongs_to :court

  has_many :candidates,    class_name: :SelectionProcedureCandidate
  has_many :commissioners, class_name: :SelectionProcedureCommissioner

  max_paginates_per 100
  paginates_per     20

  mapping do
    map :id

    analyze :organization_name
    analyze :date,          type: :date
    analyze :closed_at,     type: :date
    analyze :place
    analyze :position
    analyze :state
    analyze :workplace
    analyze :candidates,    as: lambda { |p| p.candidates.pluck(:name) }
    analyze :commissioners, as: lambda { |p| p.commissioners.pluck(:name) }

    sort_by :date, :closed_at, :created_at
  end

  facets do
    facet :q,                 type: :fulltext, field: :all
    facet :organization_name, type: :terms
    facet :candidates,        type: :terms
    facet :commissioners,     type: :terms
    facet :position,          type: :terms
    facet :state,             type: :terms, size: SelectionProcedure.pluck(:state).uniq.count
    facet :place,             type: :terms
    facet :workplace,         type: :terms
    facet :closed_at,         type: :date, interval: :month
    facet :date,              type: :date, interval: :month
  end
end