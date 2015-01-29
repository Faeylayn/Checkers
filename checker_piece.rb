#
require 'byebug'
class Piece

  attr_accessor :position, :color, :symbol, :king

  SLIDES = [
    [1,  1],
    [1, -1],
  ]

  JUMPS = [
    [2,  2],
    [2, -2]
  ]

  def initialize(board, position, color, king = false)
    @color = color
    @king = king
    @pos = position
    @board = board
    @board.add_piece(self, @pos)
    @symbol = (@color == :red) ? 'R' : "B"
  end

  def valid_pos?(position)
     if position.all? {|coord| coord.between?(0,7)}
       return false if @board.rows[position[0]][position[1]] != nil
       return true
     end
     false

  end

  def enemy_occupied?(position)
    return false if @board.rows[position[0]][position[1]] == nil
    @board.rows[position[0]][position[1]].color != false
  end


  def generate_valid_moves
    move_set = {}
#    debugger
    SLIDES.each_with_index do |(dx, dy), idx|
      dx = -dx if @color == :black
      test_pos = [@pos[0] + dx, @pos[1] + dy]
      if !enemy_occupied?(test_pos)
        move_set[test_pos] = :slide if valid_pos?(test_pos)
      else
        x, y = JUMPS[idx]
        x = -x if @color == :black
        jump_check = [@pos[0] + x, @pos[1]+ y]
        unless enemy_occupied?(jump_check)
          move_set[jump_check] = :jump if valid_pos?(jump_check)
        end

      end
    end



    if @king
      SLIDES.each_with_index do |(dx, dy), idx|
        dx = -dx if @color == :black
        test_pos = [@pos[0] - dx, @pos[1] + dy]
        if !enemy_occupied?(test_pos)
          move_set[test_pos] = :slide if valid_pos?(test_pos)
        else
          x, y = JUMPS[idx]
          x = -x if @color == :black
          jump_check = [@pos[0] - x, @pos[1]+ y]
          unless enemy_occupied?(jump_check)
            move_set[jump_check] = :jump if valid_pos?(jump_check)
          end

        end
      end


    end
    move_set
  end

  def perform_slide(new_pos)
    @board.add_piece(nil, @pos)
    @board.add_piece(self, new_pos)
    @pos = new_pos
    maybe_king
  end

  def perform_jump(new_pos)
    @board.add_piece(nil, @pos)
    @board.add_piece(self, new_pos)
    enemy_pos = [@pos[0] + ((new_pos[0]-@pos[0])/2), @pos[1] + ((new_pos[1]-@pos[1])/2)]
    @board.add_piece(nil, enemy_pos)
    @pos = new_pos
    maybe_king
  end

  def perform_moves!(sequence)
    if sequence.count == 1
      perform_slide(sequence[0])
    else

  end

  def multi_jump(sequence)
    return if sequence.count == 0
  end

  def maybe_king
    last_row = (@color == :red) ? 7 : 0

    @king = true if @position[0] == last_row

    nil
  end

  def valid_move_sequence?(sequence)

    test_board = @board.dup_board
    test_piece = test_board.rows[@pos[0]][@pos[1]]
    begin
      test_piece.perform_moves!(sequence)
    rescue

  end

end