class Package < ApplicationRecord
  has_many :participations

  has_many :author_participations, -> { where(role: Participation.roles[:author]) }, class_name: 'Participation'
  has_many :maintainer_participations, -> { where(role: Participation.roles[:maintainer]) }, class_name: 'Participation'

  has_many :authors, through: :author_participations, source: :participant, class_name: 'Participant'

  has_many :maintainers, through: :maintainer_participations, source: :participant, class_name: 'Participant'
end
