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

  def ask_action
    print '>> '
    gets.chomp.strip.downcase
  end
end
