# frozen_string_literal: true

class Knight
  attr_accessor :color, :move_i, :max_move

  def initialize(color)
    @color = color
    @move_i = [[-2, -1], [-2, 1], [-1, -2], [-1, 2], [1, -2], [1, 2], [2, -1], [2, 1]]
    @max_move = 1
  end
end
