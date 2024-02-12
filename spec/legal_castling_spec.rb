# frozen_string_literal: true

require_relative '../lib/game_board'
require_relative '../lib/legal_moves'
require_relative '../lib/legal_castling'

describe GameBoard do
  context 'When black is blocked by own piece and check on queen side, but can castle king side'
  castling = %w[
    rn..k..r
    ........
    ........
    ...R....
    ........
    ..b.....
    ........
    R...KB.R
  ]

  subject { described_class.new(castling) }

  describe '#path_clear?' do
    it 'correctly identifies the path on king side' do
      board = subject.instance_variable_get(:@board)
      expect(subject.path_clear?(board, 0, 1)).to be true
      expect(subject.path_clear?(board, 7, 1)).to be false
    end

    it 'correctly identifies the path on the queen side' do
      board = subject.instance_variable_get(:@board)
      expect(subject.path_clear?(board, 0, -1)).to be false
      expect(subject.path_clear?(board, 7, -1)).to be true
    end
  end

  describe '#path_safe?' do
    it 'identifies that the black king is moving through check' do
      board = subject.instance_variable_get(:@board)
      subject.instance_variable_get(:@king_position)['B'] = [0, 4]
      expect(subject.path_safe?(board, 'B', 'k', 0, -1)).to be false
    end

    it 'identifies that the white king is initially in check' do
      board = subject.instance_variable_get(:@board)
      subject.instance_variable_get(:@king_position)['W'] = [7, 4]
      expect(subject.path_safe?(board, 'W', 'K', 7, -1)).to be false
    end

    it 'identifies that the black king side path is safe' do
      board = subject.instance_variable_get(:@board)
      expect(subject.path_safe?(board, 'B', 'k', 0, 1)).to be true
    end
  end

  describe '#check_castling' do
    it 'returns a castling move for castling king side' do
      board = subject.instance_variable_get(:@board)
      king_position = subject.instance_variable_get(:@king_position)
      expect(subject.check_castling(board, king_position, 'B', 'k', 0, 1)).to eql(['k', [0, 4], [0, 6]])
    end

    it 'returns nil for castling queen side' do
      board = subject.instance_variable_get(:@board)
      king_position = subject.instance_variable_get(:@king_position)
      expect(subject.check_castling(board, king_position, 'B', 'k', 0, -1)).to eql(nil)
    end
  end

  describe '#legal_castling_moves' do
    it 'identifies king side castling and not queen side' do
      board = subject.instance_variable_get(:@board)
      king_position = subject.instance_variable_get(:@king_position)
      can_castle = subject.instance_variable_get(:@can_castle)
      expect(subject.legal_castling_moves(board, king_position, can_castle, 'B')).to eql([['k', [0, 4], [0, 6]]])
    end
  end
end
