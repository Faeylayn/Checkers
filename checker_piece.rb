# -*- coding: utf-8 -*-
require 'byebug'

class CheckerError < StandardError
end

class InvalidMoveError < CheckerError
end

class Piece

  attr_accessor :pos, :color, :symbol, :king

  SLIDES = [
    [1,  1],
    [1, -1],
  ]

  KING_SLIDES = [
    [-1,  1],
    [-1, -1],
  ]

  JUMPS = [
    [2,  2],
    [2, -2]
  ]

  KING_JUMPS = [
    [-2,  2],
    [-2, -2]
  ]

  def initialize(board, position, color, king = false)
    @color = color
    @king = king
    @pos = position
    @board = board
    @board.add_piece(self, @pos)
    @symbol = (@color == :red) ? 'R ' : "B "
  end


  def valid_pos?(position)
     position.all? {|coord| coord.between?(0,7)} && @board.rows[position[0]][position[1]] == nil
  end

  def enemy_occupied?(position)
    return false unless position.all? {|coord| coord.between?(0,7)}
    return false if @board.rows[position[0]][position[1]] == nil
    @board.rows[position[0]][position[1]].color != @color
  end

  def get_deltas
    deltas = SLIDES
    deltas.concat(KING_SLIDES) if @king
    deltas
  end

  def get_jumps
    jumps = JUMPS
    jumps.concat(KING_JUMPS) if @king
    jumps
  end

  def generate_valid_moves
    move_set = {}
    deltas = get_deltas
    jumps = get_jumps

    deltas.each_with_index do |(dx, dy), idx|
      dx = -dx if @color == :black
      test_pos = [@pos[0] + dx, @pos[1] + dy]

      if !enemy_occupied?(test_pos)
        move_set[test_pos] = :slide if valid_pos?(test_pos)
      else
        x, y = jumps[idx]
        x = -x if @color == :black
        jump_check = [@pos[0] + x, @pos[1]+ y]
        unless enemy_occupied?(jump_check)
          move_set[jump_check] = :jump if valid_pos?(jump_check)
        end

      end
    end

    move_set
  end

  def perform_slide(new_pos)
    moves = generate_valid_moves
    return false if moves[new_pos] != :slide
    @board.add_piece(nil, @pos)
    @board.add_piece(self, new_pos)
    @pos = new_pos
    maybe_king
    return true
  end

  def perform_jump(new_pos)
    moves = generate_valid_moves
    return false if moves[new_pos] != :jump
    @board.add_piece(nil, @pos)
    @board.add_piece(self, new_pos)
    enemy_pos = [(@pos[0] + ((new_pos[0]-@pos[0])/2)), (@pos[1] + ((new_pos[1]-@pos[1])/2))]
    @board.add_piece(nil, enemy_pos)
    @pos = new_pos
    maybe_king
    return true
  end

  def perform_moves!(sequence)
    if sequence.count == 1
      perform_slide(sequence[0]) || perform_jump(sequence[0])
    else
      multi_jump(sequence)
    end
  end

  def multi_jump(sequence)
    sequence.each do |move|
      return false unless perform_jump(move)
    end
    true
  end

  def maybe_king
    last_row = (@color == :red) ? 7 : 0
    king_symbol = (@color == :red) ? 'RK' : 'BK'

    @king = true if @pos[0] == last_row
    @symbol = king_symbol if @pos[0] == last_row
  end

  def valid_move_sequence?(sequence)
    test_board = @board.dup_board
    test_piece = test_board.rows[@pos[0]][@pos[1]]
    test_piece.perform_moves!(sequence)
  end

  def perform_moves(sequence)
    if valid_move_sequence?(sequence)
      perform_moves!(sequence)
    else
      raise InvalidMoveError
    end
  end

end
