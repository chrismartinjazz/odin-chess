# frozen_string_literal: true

class Knight
  attr_accessor :color, :step_pairs, :max_move

  def initialize(color)
    @color = color
    @step_pairs = [[-2, -1], [-2, 1], [-1, -2], [-1, 2], [1, -2], [1, 2], [2, -1], [2, 1]]
    @max_move = 1
  end

  def to_s
    'N'
  end
end
