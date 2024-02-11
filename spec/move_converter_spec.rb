# frozen_string_literal: true

require_relative '../lib/move_converter'
require_relative '../lib/pieces'

describe MoveConverter do
  subject(:move_converter) { described_class.new }

  describe '#convert'
  it 'converts a castling move by either color' do
    expect(move_converter.alg_move_to_array('O-O', 'W')).to eq(['K', [7, 4], [7, 6]])
    expect(move_converter.alg_move_to_array('0-0', 'B')).to eq(['k', [0, 4], [0, 6]])
    expect(move_converter.alg_move_to_array('O-O-O', 'B')).to eq(['k', [0, 4], [0, 2]])
    expect(move_converter.alg_move_to_array('0-0-0', 'W')).to eq(['K', [7, 4], [7, 2]])
  end

  it 'converts pawn moves and captures' do
    expect(move_converter.alg_move_to_array('e5', 'W')).to eq(['P', [nil, nil], [3, 4]])
    expect(move_converter.alg_move_to_array('dxe5', 'W')).to eq(['P', [nil, 3], [3, 4]])
    expect(move_converter.alg_move_to_array('a1', 'W')).to eq(['P', [nil, nil], [7, 0]])
  end

  it 'converts other piece moves and captures' do
    expect(move_converter.alg_move_to_array('Nb3', 'W')).to eq(['N', [nil, nil], [5, 1]])
    expect(move_converter.alg_move_to_array('Bb5', 'W')).to eq(['B', [nil, nil], [3, 1]])
    expect(move_converter.alg_move_to_array('Rd4', 'W')).to eq(['R', [nil, nil], [4, 3]])
    expect(move_converter.alg_move_to_array('Qa8', 'W')).to eq(['Q', [nil, nil], [0, 0]])
    expect(move_converter.alg_move_to_array('Kh1', 'W')).to eq(['K', [nil, nil], [7, 7]])
  end

  it 'converts with a disambiguating row' do
    expect(move_converter.alg_move_to_array('N1b3', 'W')).to eq(['N', [7, nil], [5, 1]])
  end

  it 'converts with a disambiguating column' do
    expect(move_converter.alg_move_to_array('Nab3', 'W')).to eq(['N', [nil, 0], [5, 1]])
  end

  it 'converts with a disambiguating row and column' do
    expect(move_converter.alg_move_to_array('Qa1c3', 'W')).to eq(['Q', [7, 0], [5, 2]])
  end

  it 'strips out x and + characters and still converts move' do
    expect(move_converter.alg_move_to_array('Nxb3+', 'W')).to eq(['N', [nil, nil], [5, 1]])
  end

  it 'returns nil for invalid move string' do
    expect(move_converter.alg_move_to_array('cat', 'W')).to be nil
    expect(move_converter.alg_move_to_array('!!!', 'W')).to be nil
    expect(move_converter.alg_move_to_array('Nb0', 'W')).to be nil
    expect(move_converter.alg_move_to_array('Ni5', 'W')).to be nil
    expect(move_converter.alg_move_to_array('cd3x', 'W')).to be nil
  end

  it 'allows other characters and patterns commonly used in move_converter notation' do
    expect(move_converter.alg_move_to_array('Qa1c3+ ?!', 'W')).to eq(['Q', [7, 0], [5, 2]])
    expect(move_converter.alg_move_to_array('Qa1xc3!?#', 'W')).to eq(['Q', [7, 0], [5, 2]])
  end

  describe '#array_to_alg_move' do
    it 'converts basic moves and captures back to algebraic notation' do
      queen = Queen.new('B')
      expect(move_converter.array_to_alg_move(['N', [0, 0], [2, 1]], nil)).to eql('Nb6')
      expect(move_converter.array_to_alg_move(['p', [1, 0], [3, 0]], nil)).to eql('a5')
      expect(move_converter.array_to_alg_move(['N', [0, 0], [2, 1]], queen)).to eql('Nxb6')
    end

    it 'returns castling 0-0 or 0-0-0 for castling moves' do
      expect(move_converter.array_to_alg_move(['K', [7, 4], [7, 6]], nil)).to eql('0-0')
      expect(move_converter.array_to_alg_move(['K', [7, 4], [7, 2]], nil)).to eql('0-0-0')
      expect(move_converter.array_to_alg_move(['k', [0, 4], [0, 6]], nil)).to eql('0-0')
      expect(move_converter.array_to_alg_move(['k', [0, 4], [0, 2]], nil)).to eql('0-0-0')
    end

    it 'handles pawn captures correctly' do
      pawn = Pawn.new('W')
      expect(move_converter.array_to_alg_move(['p', [1, 0], [2, 1]], pawn)).to eql('axb6')
      expect(move_converter.array_to_alg_move(['P', [4, 4], [3, 3]], pawn)).to eql('exd5')
    end

    it 'handles pawn promotion with or without capturing' do
      queen = Queen.new('W')
      rook = Rook.new('R')
      expect(move_converter.array_to_alg_move(['P', [1, 0], [0, 0]], queen)).to eql('a8Q')
      expect(move_converter.array_to_alg_move(['P', [1, 1], [0, 0]], rook)).to eql('bxa8R')
    end

    it 'indicates check appropriately' do
      queen = Queen.new('W')
      expect(move_converter.array_to_alg_move(['P', [1, 0], [0, 0]], queen, in_check: true)).to eql('a8Q+')
    end

    it 'disambiguates when two of the same piece type can move to same square' do
      expect(move_converter.array_to_alg_move(
               ['N', [0, 0], [2, 1]],
               nil,
               [
                 ['N', [0, 0], [2, 1]],
                 ['N', [0, 2], [2, 1]]
               ]
             ))
        .to eql('Nab6')
      expect(move_converter.array_to_alg_move(
               ['R', [0, 0], [4, 0]],
               nil,
               [
                 ['R', [0, 0], [4, 0]],
                 ['R', [7, 0], [4, 0]]
               ]
             ))
        .to eql('R8a4')
      expect(move_converter.array_to_alg_move(
               ['Q', [0, 0], [2, 2]],
               nil,
               [
                 ['Q', [2, 0], [2, 2]],
                 ['Q', [0, 0], [2, 2]],
                 ['Q', [0, 2], [2, 2]]
               ]
             ))
        .to eql('Qa8c6')
    end
  end
end
