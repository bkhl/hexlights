-- title:   Hexlights
-- author:  Bjoern Lindstroem <bkhl@elektrubadur.se>
-- desc:    Hexagonal lights out
-- site:    https://elektrubadur.se/
-- license: MIT License
-- version: 0.1
-- script:  lua

Q_MAX = 11
R_MAX = 11

NODE_DISTANCE = 11
NODE_RADIUS = 4

NODE_COLOURS = { 15, 12 }

BOARD_OFFSET_X = 32
BOARD_OFFSET_Y = 12

function BOOT()
    mode = mode_start
end

function TIC()
    cls(7)
    mode()
end

function mode_board()
    for q = 1, Q_MAX do
        for r = 1, R_MAX do
            x, y = node_to_point(q, r)
            circ(x, y, NODE_RADIUS, NODE_COLOURS[board[q][r]])
        end
    end
end

function mode_start()
    print("Press A to start", 10, 10)

    if btnp(4) then start_game() end
end

function start_game()
    mode = mode_board

    board = {}
    for q = 1, Q_MAX do
        board[q] = {}
        for r = 1, R_MAX do
            board[q][r] = math.random(2)
        end
    end
end

function node_to_point(q, r)
    return
        (q - 1) * NODE_DISTANCE + (r - 1) * (NODE_DISTANCE / 2) + BOARD_OFFSET_X,
        (r - 1) * NODE_DISTANCE + BOARD_OFFSET_Y
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>
