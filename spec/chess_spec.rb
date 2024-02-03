# frozen_string_literal: true

require_relative '../lib/chess'

describe Chess do
  subject(:chess) {described_class.new}

  describe '#in_legal_moves' do
    context 'in the simple case of a knight on a1' do
      it 'returns the legal move for "Nb3"' do
        move = ['N', [nil, nil], [5, 1]]
        legal_moves = [['N', [7, 0], [5, 1]], ['N', [7, 0], [6, 2]]]
        expect(chess.in_legal_moves(move, legal_moves)).to eq(['N', [7, 0], [5, 1]])
      end
    end

    context 'when disambiguation is required as there is also a knight on c1' do
      let(:legal_moves) {[
        ['N', [7, 0], [5, 1]],
        ['N', [7, 0], [6, 2]],
        ['N', [7, 2], [6, 0]],
        ['N', [7, 2], [5, 1]],
        ['N', [7, 2], [5, 3]],
        ['N', [7, 2], [6, 4]]
      ]}

      it 'returns false for "Nb3"' do
        move = ['N', [nil, nil], [5, 1]]
        expect(chess.in_legal_moves(move, legal_moves)).to be false
      end

      it 'returns true for "Nab3", as this disambiguates the move' do
        move = ['N', [nil, 0], [5, 1]]
        expect(chess.in_legal_moves(move, legal_moves)).to eq(['N', [7, 0], [5, 1]])
      end

      it 'returns false for "N1b3"' do
        move = ['N', [7, nil], [5, 1]]
        expect(chess.in_legal_moves(move, legal_moves)).to be false
      end

      it 'returns true for "Na1b3"' do
        move = ['N', [7, 0], [5, 1]]
        expect(chess.in_legal_moves(move, legal_moves)).to eq(['N', [7, 0], [5, 1]])
      end
    end
  end
end
