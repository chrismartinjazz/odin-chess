# frozen_string_literal: true

require_relative '../lib/move_converter'

describe MoveConverter do
  subject(:move_converter) { described_class.new }

  describe '#convert'
  it 'converts a castling move by either color' do
    expect(move_converter.convert('O-O', 'W')).to eq(['K', [7, 4], [7, 6]])
    expect(move_converter.convert('0-0', 'B')).to eq(['k', [0, 4], [0, 6]])
    expect(move_converter.convert('O-O-O', 'B')).to eq(['k', [0, 4], [0, 2]])
    expect(move_converter.convert('0-0-0', 'W')).to eq(['K', [7, 4], [7, 2]])
  end

  it 'converts pawn moves and captures' do
    expect(move_converter.convert('e5', 'W')).to eq(['P', [nil, nil], [3, 4]])
    expect(move_converter.convert('dxe5', 'W')).to eq(['P', [nil, 3], [3, 4]])
    expect(move_converter.convert('a1', 'W')).to eq(['P', [nil, nil], [7, 0]])
  end

  it 'converts other piece moves and captures' do
    expect(move_converter.convert('Nb3', 'W')).to eq(['N', [nil, nil], [5, 1]])
    expect(move_converter.convert('Bb5', 'W')).to eq(['B', [nil, nil], [3, 1]])
    expect(move_converter.convert('Rd4', 'W')).to eq(['R', [nil, nil], [4, 3]])
    expect(move_converter.convert('Qa8', 'W')).to eq(['Q', [nil, nil], [0, 0]])
    expect(move_converter.convert('Kh1', 'W')).to eq(['K', [nil, nil], [7, 7]])
  end

  it 'converts with a disambiguating row' do
    expect(move_converter.convert('N1b3', 'W')).to eq(['N', [7, nil], [5, 1]])
  end

  it 'converts with a disambiguating column' do
    expect(move_converter.convert('Nab3', 'W')).to eq(['N', [nil, 0], [5, 1]])
  end

  it 'converts with a disambiguating row and column' do
    expect(move_converter.convert('Qa1c3', 'W')).to eq(['Q', [7, 0], [5, 2]])
  end

  it 'strips out x and + characters and still converts move' do
    expect(move_converter.convert('Nxb3+', 'W')).to eq(['N', [nil, nil], [5, 1]])
  end

  it 'returns nil for invalid move string' do
    expect(move_converter.convert('cat', 'W')).to be nil
    expect(move_converter.convert('!!!', 'W')).to be nil
    expect(move_converter.convert('Nb0', 'W')).to be nil
    expect(move_converter.convert('Ni5', 'W')).to be nil
    expect(move_converter.convert('cd3x', 'W')).to be nil
  end

  it 'allows other characters and patterns commonly used in move_converter notation' do
    expect(move_converter.convert('Qa1c3+ ?!', 'W')).to eq(['Q', [7, 0], [5, 2]])
    expect(move_converter.convert('Qa1xc3!?#', 'W')).to eq(['Q', [7, 0], [5, 2]])
  end

  describe '#array_to_alg_move' do
    fit 'converts the move Nb6 back to algebraic notation' do
      expect(move_converter.array_to_alg_move(['N', [0, 0], [2, 1]], nil)).to eql('Nb6')
    end
  end
end
