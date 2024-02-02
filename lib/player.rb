# frozen_string_literal: true

class Player
  attr_accessor :color

  def initialize(color = 'W')
    @color = color
  end

  def ask_move
    print '>> '
    gets.chomp.strip
  end

  # ask the player their move, passing in the set of legal moves.
  # convert their input into format like e.g. ['N', [5, 1]] - piece type and color, destination sq
  #
end
