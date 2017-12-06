class Participant < ApplicationRecord
  has_many :participations
  
  has_many :author_participations, -> { where(role: Participation.roles[:author]) }, class_name: 'Participation'
  has_many :maintainer_participations, -> { where(role: Participation.roles[:maintainer]) }, class_name: 'Participation'

  has_many :packages_as_author, through: :author_participations, source: :package, class_name: 'Package'

  has_many :packages_as_maintainer, through: :maintainer_participations, source: :package, class_name: 'Package'
end
