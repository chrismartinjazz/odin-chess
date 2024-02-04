# frozen_string_literal: true

# A chess player
class Player
  attr_accessor :color

  def initialize(color = 'W')
    @color = color
  end

  def ask_move
    print '>> '
    gets.chomp.strip
  end
end
