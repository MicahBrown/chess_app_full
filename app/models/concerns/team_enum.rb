require 'active_support/concern'

module TeamEnum
  extend ActiveSupport::Concern

  included do
    enum team: %w[white black]
  end
end