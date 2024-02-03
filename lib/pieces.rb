# frozen_string_literal: true

class Pieces
  @@orthogonal = [[1, 0], [-1, 0], [0, 1], [0, -1]]
  @@diagonal = [[-1, 1], [-1, -1], [1, 1], [1, -1]]
  @@knight = [[-2, -1], [-2, 1], [-1, -2], [-1, 2], [1, -2], [1, 2], [2, -1], [2, 1]]
end

class Pawn < Pieces
  attr_accessor :color, :step_pairs, :max_move, :step_pair_movement, :step_pairs_capture

  def initialize(color)
    @color = color
    @step_pair_movement = @color == 'W' ? [-1, 0] : [1, 0]
    @step_pairs_capture = @color == 'W' ? [[-1, 1], [-1, -1]] : [[1, 1], [1, -1]]
    @max_move = 1
  end

  def to_s
    @color == 'W' ? 'P' : 'p'
  end
end

class Knight < Pieces
  attr_accessor :color, :step_pairs, :max_move

  def initialize(color)
    @color = color
    @step_pairs = @@knight
    @max_move = 1
  end

  def to_s
    @color == 'W' ? 'N' : 'n'
  end
end

class Rook < Pieces
  attr_accessor :color, :step_pairs, :max_move

  def initialize(color)
    @color = color
    @step_pairs = @@orthogonal
    @max_move = 7
  end

  def to_s
    @color == 'W' ? 'R' : 'r'
  end
end

class Bishop < Pieces
  attr_accessor :color, :step_pairs, :max_move

  def initialize(color)
    @color = color
    @step_pairs = @@diagonal
    @max_move = 7
  end

  def to_s
    @color == 'W' ? 'B' : 'b'
  end
end

class Queen < Pieces
  attr_accessor :color, :step_pairs, :max_move

  def initialize(color)
    @color = color
    @step_pairs = @@diagonal + @@orthogonal
    @max_move = 7
  end

  def to_s
    @color == 'W' ? 'Q' : 'q'
  end
end

class King < Pieces
  attr_accessor :color, :step_pairs, :max_move

  def initialize(color)
    @color = color
    @step_pairs = @@diagonal + @@orthogonal
    @max_move = 1
  end

  def to_s
    @color == 'W' ? 'K' : 'k'
  end
end
