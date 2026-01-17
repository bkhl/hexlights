-- title:   Hexlights
-- author:  Bjoern Lindstroem <bkhl@elektrubadur.se>
-- desc:    Hexagonal lights out
-- site:    https://elektrubadur.se/
-- license: MIT License
-- version: 0.1
-- script:  lua

BUTTON_UP = 0
BUTTON_DOWN = 1
BUTTON_LEFT = 2
BUTTON_RIGHT = 3

BUTTON_A = 4

Q_MAX = 11
R_MAX = 11

HEX_WIDTH = 12
HEX_VERTICAL_DISTANCE = 9

HEX_TILES = { [false] = 0, [true] = 2}

SELECT_SPRITE = 256

BOARD_OFFSET_X = 32
BOARD_OFFSET_Y = 24

STATE = {}

function _G.BOOT()
    STATE.mode = mode_start
end

function _G.TIC()
    cls(7)
    STATE.mode()
end

function mode_start()
    print("Press A to start", 20, 20)

    if btnp(BUTTON_A) then start_game() end
end

function start_game()
    STATE.mode = mode_board

    local board = {}
    for q = 1, Q_MAX do
        board[q] = {}
        for r = 1, R_MAX do
            board[q][r] = random_bool()
        end
    end

    STATE.board = board

    STATE.selected = {math.random(Q_MAX), math.random(R_MAX)}
end

function random_bool()
    if math.random(0, 1) == 1 then return true
    else return false
    end
end

function mode_board()
    handle_buttons()
    draw_board()
end

function draw_board()
    for q = 1, Q_MAX do
        for r = 1, R_MAX do
            draw_hex(HEX_TILES[STATE.board[q][r]], q, r)
        end
    end

    draw_hex(SELECT_SPRITE, table.unpack(STATE.selected))
end

function draw_hex(s, q, r)
    local x, y = hex_to_point(q, r)
    spr(s, (x - 8), (y - 8), 0, 1, 0, 0, 2, 2)
end

function handle_buttons()
    local q, r = table.unpack(STATE.selected)

    -- TODO: Handle multiple buttons pressed simultaneously to do smoother
    --       diagonal movement.

    -- TODO: Move zig-zag when moving up/down?

    if btnp(BUTTON_UP, 20, 10) then r = r - 1 end
    if btnp(BUTTON_DOWN, 20, 10) then r = r + 1 end
    if btnp(BUTTON_LEFT, 20, 10) then q = q - 1 end
    if btnp(BUTTON_RIGHT, 20, 10) then q = q + 1 end

    STATE.selected = {clamp(q, 1, Q_MAX), clamp(r, 1, R_MAX)}

    if btnp(BUTTON_A) then toggle(q, r) end
end

function toggle(q, r)
    toggle_single(q, r - 1)
    toggle_single(q + 1, r - 1)
    toggle_single(q - 1, r)
    toggle_single(q, r)
    toggle_single(q + 1, r)
    toggle_single(q - 1, r + 1)
    toggle_single(q, r + 1)
end

function toggle_single(q, r)
    if q >= 1 and q <= Q_MAX and r >= 1 and r <= R_MAX then
        STATE.board[q][r] = not STATE.board[q][r]
    end
end


function hex_to_point(q, r)
    return
        (q - 1) * HEX_WIDTH + (r - 1) * (HEX_WIDTH // 2) + BOARD_OFFSET_X,
        (r - 1) * HEX_VERTICAL_DISTANCE + BOARD_OFFSET_Y
end

function clamp(n, min, max)
    if n < min then return min
    elseif max < n then return max
    else return n
    end
end

-- <TILES>
-- 000:0000000000000000000000cc00000ccc000ccccc00cccccc00cccccc00cccccc
-- 001:0000000000000000c0000000cc000000cccc0000ccccc000ccccc000ccccc000
-- 002:0000000000000000000000ff00000fff000fffff00ffffff00ffffff00ffffff
-- 003:0000000000000000f0000000ff000000ffff0000fffff000fffff000fffff000
-- 016:00cccccc00cccccc000ccccc0000cccc000000cc000000000000000000000000
-- 017:ccccc000ccccc000cccc0000ccc00000c0000000000000000000000000000000
-- 018:00ffffff00ffffff000fffff0000ffff000000ff000000000000000000000000
-- 019:fffff000fffff000ffff0000fff00000f0000000000000000000000000000000
-- </TILES>

-- <SPRITES>
-- 000:0000000000000043000004330004330000430000043000000300000004000000
-- 001:0000000040000000340000000344000000034000000034000000030000000400
-- 016:0300000004300000004300000004300000004333000000430000000000000000
-- 017:0000030000003400000340000034000043400000400000000000000000000000
-- </SPRITES>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

