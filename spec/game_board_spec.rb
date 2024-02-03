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
  context 'When the board has just one white knight' do
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
      expect(game_board_knight.legal_moves('W')).to eq([
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

  two_knights = %w[
    n.......
    ........
    ........
    ........
    ........
    ........
    ........
    N.......
  ]

  subject(:game_board_two_knights) { described_class.new(two_knights)}
  context 'When the board has one black and one white knight' do
    it 'initializes to knights in the corner with appropriate argument' do
      expect(game_board_two_knights.board[7][0]).to be_a Knight
      expect(game_board_two_knights.board[7][1]).to be nil
      expect(game_board_two_knights.board[0][0]).to be_a Knight
      expect(game_board_two_knights.board[1][0]).to be nil
      expect(game_board_two_knights.board[7][0].color).to eql('W')
      expect(game_board_two_knights.board[0][0].color).to eql('B')
    end

    it 'returns the legal moves of the white knight' do
      expect(game_board_two_knights.legal_moves('W')).to eq([
        ['N', [7, 0], [5, 1]],
        ['N', [7, 0], [6, 2]]
      ])
    end

    it 'returns the legal moves of the black knight' do
      expect(game_board_two_knights.legal_moves('B')).to eq([
        ['n', [0, 0], [1, 2]],
        ['n', [0, 0], [2, 1]]
      ])
    end
  end

  main_pieces = %w[
    rnbqkbnr
    ........
    ........
    ........
    ........
    ........
    ........
    RNBQKBNR
  ]

  subject(:game_board_main_pieces) { described_class.new(main_pieces)}
  context 'when the board has all major pieces and no pawns' do
    it 'initializes row 1 with correct piece types' do
      expect(game_board_main_pieces.board[7][0]).to be_a Rook
      expect(game_board_main_pieces.board[7][1]).to be_a Knight
      expect(game_board_main_pieces.board[7][2]).to be_a Bishop
      expect(game_board_main_pieces.board[7][3]).to be_a Queen
      expect(game_board_main_pieces.board[7][4]).to be_a King
      expect(game_board_main_pieces.board[7][5]).to be_a Bishop
      expect(game_board_main_pieces.board[7][6]).to be_a Knight
      expect(game_board_main_pieces.board[7][7]).to be_a Rook
    end
  end

  four_pawns = %w[
    ........
    p.......
    ........
    ........
    P.......
    .p......
    P.......
    ........
  ]

  subject(:game_board_four_pawns) { described_class.new(four_pawns)}
  context 'when the board has four pawns' do
    it 'initializes with pawns of correct color' do
      expect(game_board_four_pawns.board[1][0]).to be_a Pawn
      expect(game_board_four_pawns.board[6][0]).to be_a Pawn
      expect(game_board_four_pawns.board[1][0].color).to eql('B')
      expect(game_board_four_pawns.board[6][0].color).to eql('W')
    end

    it 'finds the legal moves for the white pawns' do
      expect(game_board_four_pawns.legal_moves('W')).to eql([
        ['P', [4, 0], [3, 0]],
        ['P', [6, 0], [5, 0]],
        ['P', [6, 0], [5, 1]]
      ])
    end

    it 'finds the legal moves for the black pawns' do
      expect(game_board_four_pawns.legal_moves('B')).to eql([
        ['p', [1, 0], [2, 0]],
        ['p', [1, 0], [3, 0]],
        ['p', [5, 1], [6, 1]],
        ['p', [5, 1], [6, 0]],
      ])
    end
  end

  in_check = %w[
      k.......
      ........
      R.......
      ........
      ........
      ........
      ........
      ........
    ]
  subject (:game_board_in_check) { described_class.new(in_check) }

  context 'when in check with white rook and black king' do
    describe '#find_king' do
      it 'finds the black king on square a8' do
        expect(game_board_in_check.find_king('B')).to eql([0, 0])
      end
    end

    describe '#in_check?' do
      it 'identifies that black is in check on their move' do
        expect(game_board_in_check.in_check?('B')).to be true
      end
    end

    describe '#avoid_moving_into_check' do
      it 'removes moves that are in check' do
        initial_legal_moves = [
          ["k", [0, 0], [1, 1]],
          ["k", [0, 0], [1, 0]],
          ["k", [0, 0], [0, 1]]
        ]
        expect(game_board_in_check.avoid_moving_into_check()).to eql([
          ["k", [0, 0], [1, 1]],
          ["k", [0, 0], [0, 1]]
        ])
      end
    end
    it 'returns'
  end


end
