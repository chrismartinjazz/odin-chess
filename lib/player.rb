# frozen_string_literal: true

require_relative 'move_converter'

# A chess player
class Player
  attr_accessor :color

  def initialize(color = 'W')
    @color = color
  end
end

# A human player - enters moves via the terminal
class PlayerHuman < Player
  def ask_move(_legal_moves = nil)
    print '>> '
    gets.chomp.strip
  end

  def ask_promotion_piece
    puts 'Promote to Q - Queen : R - Rook : B - Bishop : N - Knight'
    options = %w[Q R B N]
    input = ''
    until options.include?(input)
      print '>> '
      input = gets.chomp.strip.upcase.slice(0)
    end
    input
  end
end

# A computer player - selects a random legal move
class PlayerComputer < Player
  def initialize(color)
    super(color)
    @move_converter = MoveConverter.new
  end

  def ask_move(legal_moves = nil)
    @move_converter.array_to_alg_move(legal_moves.sample)
  end

  def ask_promotion_piece
    %w[Q R B N].sample
  end
end
