require_relative 'checker_piece'

class ObstacleError < StandardError
end

class ColorError <StandardError
end



class Board
attr_accessor :rows

  def initialize(start = true)
    @start = start
    @rows = Array.new(8) {Array.new(8)}
    setup_pieces if @start
  end

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
    @rows.reverse.each do |row|
      row.each do |space|
        print " | "
        print space.symbol if space != nil
        print ' ' if space == nil
      end
      print " | "
      puts
      puts '  _______________________________'
    end
    nil
  end

  def pieces
    @rows.flatten.compact
  end

  def dup_board

    new_board = Board.new(false)

    pieces.each do |piece|
      Piece.new(new_board, piece.pos, piece.color, piece.king)
    end

    new_board
  end

  



end
