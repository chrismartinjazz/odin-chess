# frozen_string_literal: true

# A chess piece
class Pieces
  @orthogonal = [[1, 0], [-1, 0], [0, 1], [0, -1]]
  @diagonal = [[-1, 1], [-1, -1], [1, 1], [1, -1]]
  @knight = [[-2, -1], [-2, 1], [-1, -2], [-1, 2], [1, -2], [1, 2], [2, -1], [2, 1]]

  class << self
    attr_accessor :orthogonal, :diagonal, :knight
  end
end

# A chess pawn
class Pawn < Pieces
  attr_accessor :color, :step_pair_movement, :step_pairs_capture

  def initialize(color)
    super()
    @color = color
    @step_pair_movement = @color == 'W' ? [-1, 0] : [1, 0]
    @step_pairs_capture = @color == 'W' ? [[-1, 1], [-1, -1]] : [[1, 1], [1, -1]]
  end

  def to_s
    @color == 'W' ? 'P' : 'p'
  end
end

# A chess knight
class Knight < Pieces
  attr_accessor :color, :step_pairs, :max_move

  def initialize(color)
    super()
    @color = color
    @step_pairs = Pieces.knight
    @max_move = 1
  end

  def to_s
    @color == 'W' ? 'N' : 'n'
  end
end

# A chess rook
class Rook < Pieces
  attr_accessor :color, :step_pairs, :max_move

  def initialize(color)
    super()
    @color = color
    @step_pairs = Pieces.orthogonal
    @max_move = 7
  end

  def to_s
    @color == 'W' ? 'R' : 'r'
  end
end

# A chess bishop
class Bishop < Pieces
  attr_accessor :color, :step_pairs, :max_move

  def initialize(color)
    super()
    @color = color
    @step_pairs = Pieces.diagonal
    @max_move = 7
  end

  def to_s
    @color == 'W' ? 'B' : 'b'
  end
end

# A chess queen
class Queen < Pieces
  attr_accessor :color, :step_pairs, :max_move

  def initialize(color)
    super()
    @color = color
    @step_pairs = Pieces.diagonal + Pieces.orthogonal
    @max_move = 7
  end

  def to_s
    @color == 'W' ? 'Q' : 'q'
  end
end

# A chess king
class King < Pieces
  attr_accessor :color, :step_pairs, :max_move

  def initialize(color)
    super()
    @color = color
    @step_pairs = Pieces.diagonal + Pieces.orthogonal
    @max_move = 1
  end

  def to_s
    @color == 'W' ? 'K' : 'k'
  end
end
