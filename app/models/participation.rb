class Participation < ApplicationRecord
  enum role: [:author, :maintainer]

  belongs_to :package
  belongs_to :participant
end
