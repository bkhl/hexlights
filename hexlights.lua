-- title:   Hexlights
-- author:  Bjoern Lindstroem <bkhl@elektrubadur.se>
-- desc:    Hexagonal lights out
-- site:    https://elektrubadur.se/
-- license: MIT License
-- version: 0.1
-- script:  lua

Q_MAX = 11
R_MAX = 11

HEX_WIDTH = 12
HEX_VERTICAL_DISTANCE = 9

HEX_SPRITES = { 0, 2 }

SELECT_SPRITE = 4

BOARD_OFFSET_X = 32
BOARD_OFFSET_Y = 24

function BOOT()
    mode = mode_start

    start_game() -- REMOVE
end

function TIC()
    cls(7)
    mode()
end

function mode_board()
    for q = 1, Q_MAX do
        for r = 1, R_MAX do
            x, y = hex_to_point(q, r)
            spr(HEX_SPRITES[board[q][r]], (x - 8), (y - 8), 0, 1, 0, 0, 2, 2)
            if q == selected_q and r == selected_r then
                spr(SELECT_SPRITE, (x - 8), (y - 8), 0, 1, 0, 0, 2, 2)
            end
        end
    end
end

function mode_start()
    print("Press A to start", 20, 20)

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

    selected_q = math.random(Q_MAX)
    selected_r = math.random(R_MAX)
end

function hex_to_point(q, r)
    return
        (q - 1) * HEX_WIDTH + (r - 1) * (HEX_WIDTH / 2) + BOARD_OFFSET_X,
        (r - 1) * HEX_VERTICAL_DISTANCE + BOARD_OFFSET_Y
end

-- <TILES>
-- 000:0000000000000000000000cc00000ccc000ccccc00cccccc00cccccc00cccccc
-- 001:0000000000000000c0000000cc000000cccc0000ccccc000ccccc000ccccc000
-- 002:0000000000000000000000ff00000fff000fffff00ffffff00ffffff00ffffff
-- 003:0000000000000000f0000000ff000000ffff0000fffff000fffff000fffff000
-- 004:0000000000000043000004330004330000430000043000000300000004000000
-- 005:0000000040000000340000000344000000034000000034000000030000000400
-- 016:00cccccc00cccccc000ccccc0000cccc000000cc000000000000000000000000
-- 017:ccccc000ccccc000cccc0000ccc00000c0000000000000000000000000000000
-- 018:00ffffff00ffffff000fffff0000ffff000000ff000000000000000000000000
-- 019:fffff000fffff000ffff0000fff00000f0000000000000000000000000000000
-- 020:0300000004300000004300000004300000004333000000430000000000000000
-- 021:0000030000003400000340000034000043400000400000000000000000000000
-- </TILES>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>
