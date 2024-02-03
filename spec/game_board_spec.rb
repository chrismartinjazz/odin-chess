# frozen_string_literal: true

require_relative '../lib/game_board'

describe GameBoard do
  subject(:game_board) { described_class.new }

  it 'initializes to an 8 * 8 board of nil values with no argument' do
    expect game_board.board = [
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil]
    ]
  end

  one_knight = %w[
    ........
    ........
    ........
    ........
    ........
    ........
    ........
    N.......
  ]

  subject(:game_board_knight) { described_class.new(one_knight)}
  context 'When the board has just one knight' do
    it 'initializes to a white knight in the corner with appropriate argument' do
      expect(game_board_knight.board[7][0]).to be_a Knight
      expect(game_board_knight.board[7][1]).to be nil
      expect(game_board_knight.board[6][0]).to be nil
    end

    describe '#move_piece' do
      it "moves the knight to the square b3 with move (piece, starting, ending squares)" do
        board_before_move = game_board_knight.board
        game_board_knight.move_piece(['N', [7, 0], [5, 1]])
        expect(game_board_knight.board[7][0]).to be nil
        expect(game_board_knight.board[5][1]).to be_a Knight
      end
    end

    it 'returns the legal moves of the knight' do
      expect(game_board_knight.legal_moves).to eq([
        ['N', [7, 0], [5, 1]],
        ['N', [7, 0], [6, 2]]
      ])
    end

    it 'returns a string representing the board' do
      board_display = game_board_knight.display
      expect(board_display).to include('♞')
      expect(board_display).not_to include('N')

    end
  end
end

# prnbqk PRNBQK
# %w['........',
#  '........',
#  '........',
#  '........',
#  '........',
#  '........',
#  '........',
#  'N.......''
#  ]
