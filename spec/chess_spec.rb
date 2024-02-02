# frozen_string_literal: true

require_relative '../lib/chess'

describe Chess do
  subject(:chess) {described_class.new}

  describe '#convert'
  it 'converts a castling move correctly' do
    expect(chess.convert('O-O')).to eq([['K'], [], [7, 6]])
    expect(chess.convert('O-O-O')).to eq([['K'], [], [7, 2]])
  end
end
