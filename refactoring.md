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

GameOver:
move, legal_moves_list
@game_board
@current_player
@move_list
@initial_position
--> include FileManager (convert this to module)
(but for now, @file_manager)

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