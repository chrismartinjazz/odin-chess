# Structure

## Chess (278) - CLASS
- Chess knows
    - The current player
    - The sequence of moves in the game
- Chess includes
    - GameBoard class
    - Player class
    - UpdateDisplay module
    - Convert module
    - GameOver module
- Chess is responsible for
    - Running the game loop
    - Handling the end of game / save / load options. No 'change of state'.
    - Displaying the game state. No 'change of state'.

## GameBoard (164) - CLASS
- GameBoard knows
    - The state of the board
    - If castling is possible
    - If en_passant is possible
    - Where the king is (only during test_for_check... so prob move this)
- GameBoard includes
    - PositionReadWrite module
    - BoardDisplayer module
    - Pieces class
    - LegalMoves module
- GameBoard is responsible for
    - Moving pieces
    - Testing for check

## Player (47) - CLASS
- Player knows
    - Their own color
- Player holds onto
    - Convert(ComputerPlayer holds onto)
- Player includes
    - Nothing
- Player is responsible for
    - Selecting and communicating moves

## Pieces(108) - CLASS
- Each piece knows its possible directions of movement, maximum squares to move and what color it is. No change of state within a piece.

## Convert (211) - MODULE
- Convert holds onto
    - Nothing
- Convert includes
    - Nothing
- Convert is responsible for
    - Converting algebraic moves to array and vice versa

## FileManager (61) - MODULE
- Responsible for saving and loading game data, where each game is a single hash - agnostic of what is in the hash.

## PositionReadWrite (51) - MODULE
- PositionReadWrite includes
    - Pieces
- Responsible for converting a text array into a GameBoard and vice versa.

## BoardDisplayer (48) - MODULE
- BoardDisplayer knows, holds onto etc nothing. Should be a module.

### LegalMoves
- legal_moves is called from:
    - Chess
        - #game_loop (for current_player)
            @game_board.find_legal_moves
    - GameBoard
        - #in_check? (in conjunction with @king_position)
GameBoard:135