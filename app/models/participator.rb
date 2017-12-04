class Participator < ApplicationRecord
  enum role: [:author, :maintainer]
end
