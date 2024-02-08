# frozen_string_literal: true

require_relative '../lib/position_read_write'
require_relative '../lib/game_board'

describe PositionReadWrite do
  subject { described_class.new }

  context 'With an empty board' do
    position = %w[
      ........
      ........
      ........
      ........
      ........
      ........
      ........
      ........
    ]
    let(:board) { subject.read_position(position) }
    describe '#write_position' do
      it 'returns a table of dots' do
        expect(subject.write_position(board)).to eql(
          %w[
            ........
            ........
            ........
            ........
            ........
            ........
            ........
            ........
          ]
        )
      end
    end
  end

  context 'With a black and a white piece' do
    position = %w[
      Nn......
      ........
      ........
      ........
      ........
      ........
      ........
      ........
    ]
    let(:board) { subject.read_position(position) }
    describe '#write_position' do
      it 'returns pieces and dots' do
        expect(subject.write_position(board)).to eql(
          %w[
            Nn......
            ........
            ........
            ........
            ........
            ........
            ........
            ........
          ]
        )
      end
    end
  end

  context 'With the normal starting position' do
    position = %w[
      rnbqkbnr
      pppppppp
      ........
      ........
      ........
      ........
      PPPPPPPP
      RNBQKBNR
    ]
    let(:board) { subject.read_position(position) }
    describe '#write_position' do
      it 'returns correct pieces' do
        expect(subject.write_position(board)).to eql(
          %w[
            rnbqkbnr
            pppppppp
            ........
            ........
            ........
            ........
            PPPPPPPP
            RNBQKBNR
          ]
        )
      end
    end
  end
end

# position = %w[
#       rnbqkbnr
#       pppppppp
#       ........
#       ........
#       ........
#       ........
#       PPPPPPPP
#       RNBQKBNR
#     ]
