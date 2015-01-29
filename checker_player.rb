class ComputerPlayer

  def initialize(board, color)

    @board = board
    @color = color
  end

  def comp_turn

    move = find_move


  end


  def find_move
    test_board = @board.dup
    pieces = test_board.pieces.select{|piece| piece.color == @color}

    check = test_to_take_enemy

    return check unless check.nil?

    check = move_out_of_danger

  end


  def test_to_take_enemy
    test_board = @board.dup
    pieces = test_board.pieces.select{|piece| piece.color == @color}
    pieces.each do |piece|
      moves = piece.generate_valid_moves
      moves.keys.each do |move|
        if moves[move] == :jump
          piece.perform_jump(move)
          return move #unless any_in_danger?(test_board)
        end
      end
    end
    nil
  end

  def move_out_of_danger
    test_board = @board.dup
    tester = any_in_danger?(test_board)
    return nil if tester == []

    tester.each do |dx, dy|
      pos_in_danger = [(dy[0] + ((dx[0]-dy[0])/2)), (dy[1] + ((dx[1]-dy[1])/2))]
      test_moves(pos_in_danger)

    pieces = test_board.pieces.select{|piece| piece.color == @color}


  end

  def any_in_danger?(board)
    possible_danger = []
    opp_pieces = board.pieces.select{|piece| piece.color != @color}
    opp_pieces.each do |piece|
      moves = piece.generate_valid_moves
      moves.keys.each do move
        if moves[move] == :jump
          possible_danger << [move, piece.pos]
        end
      end
    end
    possible_danger
  end

  def test_moves(in_danger)



  end



end


ai_behavior

take piece if possible
move piece to safety if possible (priority king)
get king
prevent opponent king
move small towards
