# frozen_string_literal: true

require_relative '../lib/chess'

describe Chess do
  subject(:chess) {described_class.new}

  describe '#convert'
  it 'converts a castling move by either color' do
    expect(chess.convert('O-O', 'W')).to eq(['K', [7, 4], [7, 6]])
    expect(chess.convert('0-0', 'B')).to eq(['K', [0, 4], [0, 6]])
    expect(chess.convert('O-O-O', 'B')).to eq(['K', [0, 4], [0, 2]])
    expect(chess.convert('0-0-0', 'W')).to eq(['K', [7, 4], [7, 2]])
  end

  it 'converts pawn moves and captures' do
    expect(chess.convert('e5')).to eq(['P', [nil, nil], [3, 4]])
    expect(chess.convert('dxe5')).to eq(['P', [nil, 3], [3, 4]])
    expect(chess.convert('a1')).to eq(['P', [nil, nil], [7, 0]])
  end

  it 'converts other piece moves and captures' do
    expect(chess.convert('Nb3')).to eq(['N', [nil, nil], [5, 1]])
    expect(chess.convert('Bb5')).to eq(['B', [nil, nil], [3, 1]])
    expect(chess.convert('Rd4')).to eq(['R', [nil, nil], [4, 3]])
    expect(chess.convert('Qa8')).to eq(['Q', [nil, nil], [0, 0]])
    expect(chess.convert('Kh1')).to eq(['K', [nil, nil], [7, 7]])
  end

  it 'converts with a disambiguating row' do
    expect(chess.convert('N1b3')).to eq(['N', [7, nil], [5, 1]])
  end

  it 'converts with a disambiguating column' do
    expect(chess.convert('Nab3')).to eq(['N', [nil, 0], [5, 1]])
  end

  it 'converts with a disambiguating row and column' do
    expect(chess.convert('Qa1c3')).to eq(['Q', [7, 0], [5, 2]])
  end

  it 'strips out x and + characters and still converts move' do
    expect(chess.convert('Nxb3+')).to eq(['N', [nil, nil], [5, 1]])
  end

  it 'returns nil for invalid move string' do
    expect(chess.convert('cat')).to be nil
    expect(chess.convert('!!!')).to be nil
    expect(chess.convert('Nb0')).to be nil
    expect(chess.convert('Ni5')).to be nil
    expect(chess.convert('cd3x')).to be nil

  end

  it 'allows other characters and patterns commonly used in chess notation' do
    expect(chess.convert('Qa1c3+ ?!')).to eq(['Q', [7, 0], [5, 2]])
    expect(chess.convert('Qa1xc3!?#')).to eq(['Q', [7, 0], [5, 2]])
  end
end
