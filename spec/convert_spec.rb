# frozen_string_literal: true

require_relative '../lib/convert'
require_relative '../lib/pieces'

describe Convert do
  # subject(:move_converter) { described_class.new }

  describe '#convert' do
    describe '#text_to_array' do
      it 'converts a castling move by either color' do
        expect(Convert::TextToArray.text_to_array('O-O', 'W')).to eq(['K', [7, 4], [7, 6]])
        expect(Convert::TextToArray.text_to_array('0-0', 'B')).to eq(['k', [0, 4], [0, 6]])
        expect(Convert::TextToArray.text_to_array('O-O-O', 'B')).to eq(['k', [0, 4], [0, 2]])
        expect(Convert::TextToArray.text_to_array('0-0-0', 'W')).to eq(['K', [7, 4], [7, 2]])
      end

      it 'converts pawn moves and captures' do
        expect(Convert::TextToArray.text_to_array('e5', 'W')).to eq(['P', [nil, nil], [3, 4]])
        expect(Convert::TextToArray.text_to_array('dxe5', 'W')).to eq(['P', [nil, 3], [3, 4]])
        expect(Convert::TextToArray.text_to_array('a1', 'W')).to eq(['P', [nil, nil], [7, 0]])
      end

      it 'converts other piece moves and captures' do
        expect(Convert::TextToArray.text_to_array('Nb3', 'W')).to eq(['N', [nil, nil], [5, 1]])
        expect(Convert::TextToArray.text_to_array('Bb5', 'W')).to eq(['B', [nil, nil], [3, 1]])
        expect(Convert::TextToArray.text_to_array('Rd4', 'W')).to eq(['R', [nil, nil], [4, 3]])
        expect(Convert::TextToArray.text_to_array('Qa8', 'W')).to eq(['Q', [nil, nil], [0, 0]])
        expect(Convert::TextToArray.text_to_array('Kh1', 'W')).to eq(['K', [nil, nil], [7, 7]])
      end

      it 'converts with a disambiguating row' do
        expect(Convert::TextToArray.text_to_array('N1b3', 'W')).to eq(['N', [7, nil], [5, 1]])
      end

      it 'converts with a disambiguating column' do
        expect(Convert::TextToArray.text_to_array('Nab3', 'W')).to eq(['N', [nil, 0], [5, 1]])
      end

      it 'converts with a disambiguating row and column' do
        expect(Convert::TextToArray.text_to_array('Qa1c3', 'W')).to eq(['Q', [7, 0], [5, 2]])
      end

      it 'strips out x and + characters and still converts move' do
        expect(Convert::TextToArray.text_to_array('Nxb3+', 'W')).to eq(['N', [nil, nil], [5, 1]])
      end

      it 'returns nil for invalid move string' do
        expect(Convert::TextToArray.text_to_array('cat', 'W')).to be nil
        expect(Convert::TextToArray.text_to_array('!!!', 'W')).to be nil
        expect(Convert::TextToArray.text_to_array('Nb0', 'W')).to be nil
        expect(Convert::TextToArray.text_to_array('Ni5', 'W')).to be nil
        expect(Convert::TextToArray.text_to_array('cd3x', 'W')).to be nil
      end

      it 'allows other characters and patterns commonly used in move_converter notation' do
        expect(Convert::TextToArray.text_to_array('Qa1c3+ ?!', 'W')).to eq(['Q', [7, 0], [5, 2]])
        expect(Convert::TextToArray.text_to_array('Qa1xc3!?#', 'W')).to eq(['Q', [7, 0], [5, 2]])
      end
    end

    describe '#array_to_text' do
      it 'converts basic moves and captures back to algebraic notation' do
        queen = Queen.new('B')
        expect(Convert::ArrayToText.array_to_text(['N', [0, 0], [2, 1]], nil)).to eql('Nb6')
        expect(Convert::ArrayToText.array_to_text(['p', [1, 0], [3, 0]], nil)).to eql('a5')
        expect(Convert::ArrayToText.array_to_text(['N', [0, 0], [2, 1]], queen)).to eql('Nxb6')
      end

      it 'returns castling 0-0 or 0-0-0 for castling moves' do
        expect(Convert::ArrayToText.array_to_text(['K', [7, 4], [7, 6]], nil)).to eql('0-0')
        expect(Convert::ArrayToText.array_to_text(['K', [7, 4], [7, 2]], nil)).to eql('0-0-0')
        expect(Convert::ArrayToText.array_to_text(['k', [0, 4], [0, 6]], nil)).to eql('0-0')
        expect(Convert::ArrayToText.array_to_text(['k', [0, 4], [0, 2]], nil)).to eql('0-0-0')
      end

      it 'handles pawn captures correctly' do
        pawn = Pawn.new('W')
        expect(Convert::ArrayToText.array_to_text(['p', [1, 0], [2, 1]], pawn)).to eql('axb6')
        expect(Convert::ArrayToText.array_to_text(['P', [4, 4], [3, 3]], pawn)).to eql('exd5')
      end

      it 'handles pawn promotion with or without capturing' do
        queen = Queen.new('W')
        rook = Rook.new('R')
        expect(Convert::ArrayToText.array_to_text(['P', [1, 0], [0, 0]], queen)).to eql('a8Q')
        expect(Convert::ArrayToText.array_to_text(['P', [1, 1], [0, 0]], rook)).to eql('bxa8R')
      end

      it 'indicates check appropriately' do
        queen = Queen.new('W')
        expect(Convert::ArrayToText.array_to_text(['P', [1, 0], [0, 0]], queen, in_check: true)).to eql('a8Q+')
      end

      it 'disambiguates when two of the same piece type can move to same square' do
        expect(Convert::ArrayToText.array_to_text(
                 ['N', [0, 0], [2, 1]],
                 nil,
                 [
                   ['N', [0, 0], [2, 1]],
                   ['N', [0, 2], [2, 1]]
                 ]
               ))
          .to eql('Nab6')
        expect(Convert::ArrayToText.array_to_text(
                 ['R', [0, 0], [4, 0]],
                 nil,
                 [
                   ['R', [0, 0], [4, 0]],
                   ['R', [7, 0], [4, 0]]
                 ]
               ))
          .to eql('R8a4')
        expect(Convert::ArrayToText.array_to_text(
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

    describe '#text_to_array' do
      context 'in the simple case of a knight on a1' do
        it 'returns the legal move for "Nb3"' do
          move = ['N', [nil, nil], [5, 1]]
          legal_moves = [['N', [7, 0], [5, 1]], ['N', [7, 0], [6, 2]]]
          expect(Convert::TextToArray.send(:match_legal_moves, move, legal_moves)).to eq(['N', [7, 0], [5, 1]])
        end
      end

      context 'when disambiguation is required as there is also a knight on c1' do
        let(:legal_moves) do
          [
            ['N', [7, 0], [5, 1]],
            ['N', [7, 0], [6, 2]],
            ['N', [7, 2], [6, 0]],
            ['N', [7, 2], [5, 1]],
            ['N', [7, 2], [5, 3]],
            ['N', [7, 2], [6, 4]]
          ]
        end

        it 'returns false for "Nb3"' do
          move = ['N', [nil, nil], [5, 1]]
          expect(Convert::TextToArray.send(:match_legal_moves, move, legal_moves)).to be false
        end

        it 'returns true for "Nab3", as this disambiguates the move' do
          move = ['N', [nil, 0], [5, 1]]
          expect(Convert::TextToArray.send(:match_legal_moves, move, legal_moves)).to eq(['N', [7, 0], [5, 1]])
        end

        it 'returns false for "N1b3"' do
          move = ['N', [7, nil], [5, 1]]
          expect(Convert::TextToArray.send(:match_legal_moves, move, legal_moves)).to be false
        end

        it 'returns true for "Na1b3"' do
          move = ['N', [7, 0], [5, 1]]
          expect(Convert::TextToArray.send(:match_legal_moves, move, legal_moves)).to eq(['N', [7, 0], [5, 1]])
        end
      end
    end
  end
end
