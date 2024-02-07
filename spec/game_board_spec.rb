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

  subject(:game_board_knight) { described_class.new(one_knight) }

  context 'When the board has just one white knight' do
    it 'initializes to a white knight in the corner with appropriate argument' do
      expect(game_board_knight.board[7][0]).to be_a Knight
      expect(game_board_knight.board[7][1]).to be nil
      expect(game_board_knight.board[6][0]).to be nil
    end

    describe '#move_piece' do
      it 'moves the knight to the square b3 with move (piece, starting, ending squares)' do
        board_before_move = game_board_knight.board
        game_board_knight.move_piece(['N', [7, 0], [5, 1]])
        expect(game_board_knight.board[7][0]).to be nil
        expect(game_board_knight.board[5][1]).to be_a Knight
      end
    end

    describe '#legal_moves' do
      it 'returns the legal moves of the knight' do
        game_board_knight.instance_variable_set(:@can_castle, { w_king_side: false, w_queen_side: false })
        expect(game_board_knight.legal_moves('W')).to eq([
                                                           ['N', [7, 0], [5, 1]],
                                                           ['N', [7, 0], [6, 2]]
                                                         ])
      end
    end

    describe '#display' do
      it 'returns a string representing the board' do
        board_display = game_board_knight.display
        expect(board_display).to include('♞')
        expect(board_display).not_to include('N')
      end
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

  subject(:game_board_two_knights) { described_class.new(two_knights) }
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
      game_board_two_knights.instance_variable_set(:@can_castle, { w_king_side: false, w_queen_side: false })
      expect(game_board_two_knights.legal_moves('W')).to eq([
                                                              ['N', [7, 0], [5, 1]],
                                                              ['N', [7, 0], [6, 2]]
                                                            ])
    end

    it 'returns the legal moves of the black knight' do
      game_board_two_knights.instance_variable_set(:@can_castle, { b_king_side: false, b_queen_side: false })
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

  subject(:game_board_main_pieces) { described_class.new(main_pieces) }
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

  subject(:game_board_four_pawns) { described_class.new(four_pawns) }
  context 'when the board has four pawns' do
    it 'initializes with pawns of correct color' do
      expect(game_board_four_pawns.board[1][0]).to be_a Pawn
      expect(game_board_four_pawns.board[6][0]).to be_a Pawn
      expect(game_board_four_pawns.board[1][0].color).to eql('B')
      expect(game_board_four_pawns.board[6][0].color).to eql('W')
    end

    it 'finds the legal moves for the white pawns' do
      game_board_four_pawns.instance_variable_set(:@can_castle, { w_king_side: false, w_queen_side: false })
      expect(game_board_four_pawns.legal_moves('W')).to eql(
        [
          ['P', [4, 0], [3, 0]],
          ['P', [6, 0], [5, 0]],
          ['P', [6, 0], [5, 1]]
        ]
      )
    end

    it 'finds the legal moves for the black pawns' do
      game_board_four_pawns.instance_variable_set(:@can_castle, { b_king_side: false, b_queen_side: false })
      expect(game_board_four_pawns.legal_moves('B')).to eql([
                                                              ['p', [1, 0], [2, 0]],
                                                              ['p', [1, 0], [3, 0]],
                                                              ['p', [5, 1], [6, 1]],
                                                              ['p', [5, 1], [6, 0]]
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
  subject(:game_board_in_check) { described_class.new(in_check) }

  context 'when in check with white rook and black king' do
    describe '#find_king' do
      it 'finds the black king on square a8' do
        expect(game_board_in_check.find_king('B')).to eql([0, 0])
      end
    end

    describe '#in_check?' do
      it 'identifies that black is in check on their move' do
        game_board_in_check.instance_variable_set(:@king_position, [0, 0])
        expect(game_board_in_check.in_check?('B')).to be true
      end
    end

    describe '#avoid_moving_into_check' do
      it 'removes moves that are in check' do
        expect(game_board_in_check.legal_moves('B')).to eql([
                                                              ['k', [0, 0], [1, 1]],
                                                              ['k', [0, 0], [0, 1]]
                                                            ])
      end
    end
  end

  castling = %w[
    r...k..r
    .....ppp
    ........
    ........
    ........
    ........
    .....PPP
    R...K..R
  ]
  subject(:game_board_castling) { described_class.new(castling) }

  context 'when castling is possible king side' do
    it 'identifies castling moves for black and white king' do
      expect(game_board_castling.legal_moves('B')).to include(['k', [0, 4], [0, 6]])
      expect(game_board_castling.legal_moves('W')).to include(['K', [7, 4], [7, 6]])
    end
  end

  describe '#castling?' do
    it 'identifies if a move is a castling move for black' do
      move = ['k', [0, 4], [0, 2]]
      expect(game_board_castling.castling?(move)).to be true
    end

    it 'identifies if a move is a castling move for white' do
      move = ['K', [0, 4], [0, 6]]
      expect(game_board_castling.castling?(move)).to be true
    end

    it 'identifies a normal king move as not castling' do
      move = ['k', [0, 3], [0, 2]]
      expect(game_board_castling.castling?(move)).to be false
    end
  end

  describe '#castle' do
    it 'moves the rook for black' do
      move = ['k', [0, 4], [0, 2]]
      game_board_castling.castle(move)
      expect(game_board_castling.board[0][3]).to be_a Rook
    end

    it 'moves the rook for white' do
      move = ['K', [7, 4], [7, 6]]
      game_board_castling.castle(move)
      expect(game_board_castling.board[7][5]).to be_a Rook
    end
  end

  starting_pos = %w[
    rnbqkbnr
    pppppppp
    ........
    ........
    ........
    ........
    PPPPPPPP
    RNBQKBNR
  ]
  subject(:game_board_starting_pos) { described_class.new(starting_pos) }
  context 'When moving into castling position' do
    describe '#move_piece' do
      it 'plays a legal sequence of moves including castling' do
        game_board_starting_pos.move_piece(['P', [6, 4], [4, 4]])
        game_board_starting_pos.move_piece(['p', [1, 4], [3, 4]])
        game_board_starting_pos.move_piece(['N', [7, 6], [5, 5]])
        game_board_starting_pos.move_piece(['n', [0, 6], [2, 5]])
        game_board_starting_pos.move_piece(['B', [7, 5], [6, 4]])
        game_board_starting_pos.move_piece(['b', [0, 5], [1, 4]])
        expect(game_board_starting_pos.board[7][4]).to be_a King
        expect(game_board_starting_pos.board[7][7]).to be_a Rook
        game_board_starting_pos.move_piece(['K', [7, 4], [7, 6]])
        expect(game_board_starting_pos.board[7][6]).to be_a King
        expect(game_board_starting_pos.board[7][5]).to be_a Rook
      end
    end
  end

  pawn_prom = %w[
    ......k.
    PK......
    ...P....
    ........
    ........
    ........
    ........
    ........
  ]

  subject(:board_pawn_prom) { described_class.new(pawn_prom) }

  context 'When a pawn is promoting' do
    describe '#pawn_promoting?' do
      it 'identifies a pawn promotion move' do
        move = ['P', [1, 0], [0, 0]]
        expect(board_pawn_prom.pawn_promoting?(move)).to be true
      end

      it 'identifies a pawn move that is not a promotion' do
        move = ['P', [2, 3], [1, 3]]
        expect(board_pawn_prom.pawn_promoting?(move)).to be false
      end
    end

    describe '#promote_pawn' do
      before do
        allow(board_pawn_prom).to receive(:ask_promotion_piece) { 'Q' }
        $stdout = StringIO.new
      end

      it 'promotes a pawn to a queen' do
        move = ['P', [1, 0], [0, 0]]

        board_pawn_prom.move_piece(move)
        expect(board_pawn_prom.board[0][0]).to be_a Queen
        expect(board_pawn_prom.board[1][0]).to be nil
      end
    end

    describe '#promote_pawn' do
      before do
        allow(board_pawn_prom).to receive(:ask_promotion_piece) { 'R' }
        $stdout = StringIO.new
      end

      it 'promotes a pawn to a rook' do
        move = ['P', [1, 0], [0, 0]]

        board_pawn_prom.move_piece(move)
        expect(board_pawn_prom.board[0][0]).to be_a Rook
        expect(board_pawn_prom.board[1][0]).to be nil
      end
    end
  end

  en_passant = %w[
    ........
    p.......
    ........
    .P......
    ........
    ........
    ........
    ........
  ]

  subject(:board_en_passant) { described_class.new(en_passant) }

  context 'When a pawn advances two squares' do
    describe '#pawn_two_square_advance' do
      it 'adds the appropriate square to en_passant_options' do
        move = ['p', [1, 0], [3, 0]]
        expect(board_en_passant.instance_variable_get(:@en_passant_option)).to be nil
        board_en_passant.pawn_two_square_advance(move)
        expect(board_en_passant.instance_variable_get(:@en_passant_option)).to eql([2, 0])
      end
    end

    describe '#move_piece' do
      it 'adds the appropriate square to en_passant_options' do
        move = ['p', [1, 0], [3, 0]]
        expect(board_en_passant.instance_variable_get(:@en_passant_option)).to be nil
        board_en_passant.move_piece(move)
        expect(board_en_passant.instance_variable_get(:@en_passant_option)).to eql([2, 0])
      end
    end

    describe '#legal_moves' do
      it 'identifies en_passant capture as a legal move' do
        move = ['p', [1, 0], [3, 0]]
        board_en_passant.instance_variable_set(:@can_castle, { w_king_side: false, w_queen_side: false })

        board_en_passant.pawn_two_square_advance(move)
        expect(board_en_passant.legal_moves('W')).to eql(
          [
            ['P', [3, 1], [2, 1]],
            ['P', [3, 1], [2, 0]]
          ]
        )
      end
    end

    describe '#en_passant_capture' do
      it 'removes the pawn captured by en passant' do
        black_move = ['p', [1, 0], [3, 0]]
        board_en_passant.move_piece(black_move)

        white_move = ['P', [3, 1], [2, 0]]
        expect(board_en_passant.board[3][0]).to be_a Pawn
        board_en_passant.en_passant_capture(white_move)
        expect(board_en_passant.board[3][0]).to be nil
      end

      it 'returns the captured piece' do
        black_move = ['p', [1, 0], [3, 0]]
        board_en_passant.move_piece(black_move)

        white_move = ['P', [3, 1], [2, 0]]
        return_value = board_en_passant.en_passant_capture(white_move)
        expect(return_value).to be_a Pawn
      end
    end
  end
end
