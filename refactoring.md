@king_position.
- GameBoard
    - #initialize to nil
    - We call find_king to update it just before in_check? in #test_for_check?, because we may have just moved the king.
    - We call find_king to update it in #undo_move in case we have moved the king back.
- LegalMoves
    - We call find_king to update it at the very start of legal_moves, so it is updated prior to that chain of actions
The reason why we have this convolution is because legal_moves is called both to find all legal moves prior to moving, and every time we test for check (most often recursively).
However this is not necessary - to test for check it would be much more efficient to:

find_king at the start of testing for legal_moves
test_for_check?(move = nil, king_position)
- Make the given move (nil if not given - update king_position if we just moved it)
    - Iterate from the king position over orthogonal and diagonal directions looking for opposing pieces. Break if off the board
    - When find a piece, check its type.
        - knight - return true if knight && distance == 1
        - orthogonal - return true if rook, queen, king && distance == 1
        - diagonal - return true if bishop, queen, king && distance == 1
        - pawn_diagonal - return true if distance == 1 (pawn has to be initialized based on color of the king)
- Undo the move

Rethinking again...
Chess --> Board: What are the legal moves for white?
Init a set of moves
For every square...
    If it contains a white piece...
        For every direction that piece moves...
            For every distance up to maximum...
                Is it nil?
                    Add it to moves and keep going
                Is it off the board?
                    Next direction
                Is it occupied by black piece?
                    Add it to moves and next direction.
                Is it occupied by white piece?
                    Next direction
For every move in the set of moves...
    (Test: if white makes this move, are they in check?)
    Make the move on the board
    

# Structure

## Chess (278)
- Chess knows
    - The current player
    - The sequence of moves in the game
- Chess holds onto
    - GameBoard @game_board
    - Player @player1 @player2
    - MoveConverter @move_converter
    - FileManager @file_manager
- Chess includes
    - Nothing
- Chess is responsible for
    - Running the game loop
    - Identifying if a given move is unique in the set of legal moves (could move to MoveConverter?). No 'change of state' involved
    - Handling the end of game / save / load options. No 'change of state'.
    - Displaying the game state. No 'change of state'.

---

## GameBoard (164)
- GameBoard knows
    - The state of the board
    - If castling is possible
    - If en_passant is possible
    - Where the king is (only during test_for_check... so prob move this)
- GameBoard holds onto
    - PositionReadWrite @position_read_write
    - BoardDisplayer @board_displayer
- GameBoard includes
    - Pieces
    - LegalMoves
- GameBoard is responsible for
    - Moving pieces
    - Testing for check

## Player (47)
- Player knows
    - Their own color
- Player holds onto
    - MoveConverter(ComputerPlayer holds onto)
- Player includes
    - Nothing
- Player is responsible for
    - Selecting and communicating moves

## MoveConverter (173)
- MoveConverter knows
    - Constants only - regex validations and hashes. It should be a module.
- MoveConverter holds onto
    - Nothing
- MoveConverter includes
    - Nothing
- MoveConverter is responsible for
    - Converting algebraic moves to array and vice versa

## FileManager (61)
- FileManager knows
    - Nothing - it should be a module!
- Responsible for saving and loading game data, where each game is a single hash - agnostic of what is in the hash.

---

### PositionReadWrite (51)
- PositionReadWrite knows
    - Just a constant - Piece-Map. It should be a module.
- PositionReadWrite includes
    - Pieces
- Responsible for converting a text array into a GameBoard and vice versa.

### BoardDisplayer (48)
- BoardDisplayer knows, holds onto etc nothing. Should be a module.

### Pieces(108)
- Each piece knows its possible directions of movement, maximum squares to move and what color it is. No change of state within a piece.

### LegalMoves
- legal_moves is called from:
    - Chess
        - #game_loop (for current_player)
    - GameBoard
        - #in_check? (in conjunction with @king_position)