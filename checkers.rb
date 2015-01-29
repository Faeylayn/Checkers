require_relative 'checker_piece'
require_relative 'checker_player'

class ObstacleError < StandardError
end

class ColorError <StandardError
end



class Board
attr_accessor :rows

  def initialize(start = true)
    @rows = Array.new(8) {Array.new(8)}
    setup_pieces if start
  end

  # def setup_pieces
  #   #test
  #   Piece.new(self, [3,3], :red)
  #   Piece.new(self, [4,4], :black)
  #   Piece.new(self, [1,3], :red)
  #   Piece.new(self, [0,7], :red)
  # end

  def setup_pieces
    (0..2).each do |idx|
      setup_row(@rows[idx], (idx % 2), :red, idx)
      setup_row(@rows[((@rows.count - 1) - idx)], ((idx+1) % 2), :black, (@rows.count-1 -idx))
    end
  end

  def setup_row(row, mod, color, index)
    row.each_with_index do |space, idx|
      if mod == idx % 2
        Piece.new(self, [index, idx], color)
      end
    end
  end

  def add_piece(piece, position)
    @rows[position[0]][position[1]] = piece
  end

  def display
    puts '  _______________________________________'
    nums = (0..7).to_a
    @rows.reverse.each do |row|
      print "#{nums.pop}"
      row.each do |space|
        print " | "
        print space.symbol if space != nil
        print '  ' if space == nil
      end
      print " | "
      puts
      puts '   _______________________________________'
    end

    puts '    0    1    2    3    4    5    6    7  '
    nil
  end

  def pieces
    @rows.flatten.compact
  end

  def dup_board
    new_board = Board.new(false)
    pieces.each do |piece|
      Piece.new(new_board, piece.pos.dup, piece.color, piece.king)
    end

    new_board
  end

end


class Game
  def initialize

    @board = Board.new
    @current_color = :red
    @game_on = true
    #play
  end


  def play
    puts "Welcome to Checkers!"

    while @game_on

      @board.display
      puts "It is #{@current_color}'s turn"
      begin
        user_turn
      rescue ColorError
        puts "That is not a valid piece to move"
        retry
      rescue InvalidMoveError
        puts "That is not a Valid Move or Move sequence!"
        retry
      rescue ArgumentError
        puts "Invalid Input"
        retry
      rescue TypeError
        puts "Invalid Input"
        retry
      end

      @current_color = (@current_color == :red) ? :black : :red

      unless lose_check
        @game_on = false
        @board.display
        puts "#{@current_color} is out of pieces!"
        puts "YOU LOSE! YOU GET NOTHING! GOOD DAY SIR!"
      end

    end
  end

  def user_turn
    puts "Which piece would you like to move? i.e. 00"

    moving_piece = get_moving_piece

    puts "Where would you like to move to?"
    puts "If there are multiple jumps, please separate them by commas."
    puts "i.e. 24, 42, 64"

    move_sequence = get_move_sequence
    moving_piece.perform_moves(move_sequence)

  end

  def get_moving_piece
    input = gets.chomp.split('')
    input[0] = Integer(input[0])
    input[1] = Integer(input[1])
    moving_piece = @board.rows[input[0]][input[1]]

    raise ColorError if moving_piece == nil
    raise ColorError if moving_piece.color != @current_color

    moving_piece
  end

  def get_move_sequence
    move_sequence = []
    move_input = gets.chomp.split(',')
    move_input.each do |move|
      move = move.strip.split('')
      move[0] = Integer(move[0])
      move[1] = Integer(move[1])
      move_sequence << move
    end
    move_sequence
  end

  def lose_check
    @board.pieces.any? {|piece| piece.color == @current_color}
  end

end
