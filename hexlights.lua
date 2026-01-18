-- title:   Hexlights
-- author:  Bjoern Lindstroem <bkhl@elektrubadur.se>
-- desc:    Hexagonal lights out
-- site:    https://github.com/bkhl/hexlights
-- license: MIT License
-- version: 0.1
-- script:  lua
-- input:   gamepad


--------------------------------------------------------------------------------
--
-- Constants
--

BUTTON_UP    = 0
BUTTON_DOWN  = 1
BUTTON_LEFT  = 2
BUTTON_RIGHT = 3

BUTTON_B = 5

DIRECTION_UP_LEFT    = 0
DIRECTION_UP_RIGHT   = 1
DIRECTION_RIGHT      = 2
DIRECTION_DOWN_RIGHT = 3
DIRECTION_DOWN_LEFT  = 4
DIRECTION_LEFT       = 5

DIRECTION_TO_VELOCITY = {
    [DIRECTION_UP_LEFT]    = { 0, -1},
    [DIRECTION_UP_RIGHT]   = { 1, -1},
    [DIRECTION_RIGHT]      = { 1,  0},
    [DIRECTION_DOWN_RIGHT] = { 0,  1},
    [DIRECTION_DOWN_LEFT]  = {-1,  1},
    [DIRECTION_LEFT]       = {-1,  0}
}

Q_MAX = 11
R_MAX = 11

HEX_WIDTH = 12
HEX_VERTICAL_DISTANCE = 9

HEX_TILES = { [false] = 0, [true] = 2}

SELECT_SPRITE = 256

BOARD_OFFSET_X = 32
BOARD_OFFSET_Y = 24


--------------------------------------------------------------------------------
-- Game state

STATE = {}


--------------------------------------------------------------------------------
-- TIC-80 Callbacks

function _G.BOOT()
    STATE.mode = mode_start
end

function _G.TIC()
    cls(7)
    STATE.mode()
end


--------------------------------------------------------------------------------
-- Start screen

function mode_start()
    print("Press B to start", 32, 48, 12, nil, 2)

    if btnp(BUTTON_B) then start_game() end
end


--------------------------------------------------------------------------------
-- Game board

function mode_board()
    handle_buttons_board()

    if game_won() then end_game() end

    draw_board()
end

function start_game()
    local board = {}
    for q = 1, Q_MAX do
        board[q] = {}
        for r = 1, R_MAX do
            board[q][r] = false
        end
    end
    for q = 1, Q_MAX do
        for r = 1, R_MAX do
            if math.random(0, 1) == 1 then
                toggle(board, q, r)
            end
        end
    end

    STATE.mode = mode_board
    STATE.board = board

    STATE.selected = {math.random(Q_MAX), math.random(R_MAX)}
end

function draw_board()
    for q = 1, Q_MAX do
        for r = 1, R_MAX do
            draw_hex(HEX_TILES[STATE.board[q][r]], q, r)
        end
    end

    if STATE.selected then
        draw_hex(SELECT_SPRITE, table.unpack(STATE.selected))
    end
end

function draw_hex(s, q, r)
    local x, y = hex_to_point(q, r)
    spr(s, (x - 8), (y - 8), 0, 1, 0, 0, 2, 2)
end

function handle_buttons_board()
    local q, r = table.unpack(STATE.selected)

    local direction = get_hexagonal_button_direction(r)

    -- FIXME: Holding up/down should keep counter going even though we're moving
    --        zigzag.

    -- FIXME: Make logic around diagonal moves smoother. Maybe just treat plain
    --        r movement as the baseline if up/down is pressed, and just use
    --        simultaneous hold of left/right as a hint?

    if direction then
        if direction == STATE.direction then
            if STATE.direction_hold_frames == 0 then
                move_selection(direction)
                STATE.direction_hold_frames = STATE.direction_hold_frames + 1
            elseif STATE.direction_hold_frames == 20 then
                move_selection(direction)
                STATE.direction_hold_frames = 10
            else
                STATE.direction_hold_frames = STATE.direction_hold_frames + 1
            end
        else
            STATE.direction_hold_frames = 0
        end
        STATE.direction = direction
    else
        STATE.direction = nil
        STATE.direction_hold_frames = nil
    end

    if btnp(BUTTON_B) then toggle(STATE.board, q, r) end
end

function move_selection(direction)
    local q, r = table.unpack(STATE.selected)
    local velocity_q, velocity_r = table.unpack(DIRECTION_TO_VELOCITY[direction])
    q, r = q + velocity_q, r + velocity_r
    STATE.selected = {clamp(q, 1, Q_MAX), clamp(r, 1, R_MAX)}
end

--[[
    Work out current direction to move based on combination of pressed D-pad
    buttons.

    Pressing up+down or left+right simultaneously will cancel out.
--]]
function get_hexagonal_button_direction(r)
    if btn(BUTTON_UP) then
        if btn(BUTTON_DOWN) then
            if btn(BUTTON_LEFT) then
                if not btn(BUTTON_RIGHT) then
                    return DIRECTION_LEFT
                end
            elseif btn(BUTTON_RIGHT) then
                return DIRECTION_RIGHT
            end
        else
            if btn(BUTTON_LEFT) then
                return DIRECTION_UP_LEFT
            elseif btn(BUTTON_RIGHT) then
                return DIRECTION_UP_RIGHT
            elseif r % 2 == 0 then
                return DIRECTION_UP_LEFT
            else
                return DIRECTION_UP_RIGHT
            end
        end
    elseif btn(BUTTON_DOWN) then
        if btn(BUTTON_LEFT) then
            if not btn(BUTTON_RIGHT) then
                return DIRECTION_DOWN_LEFT
            end
        elseif btn(BUTTON_RIGHT) then
            return DIRECTION_DOWN_RIGHT
        elseif r % 2 == 0 then
            return DIRECTION_DOWN_LEFT
        else
            return DIRECTION_DOWN_RIGHT
        end
    else
        if btn(BUTTON_LEFT) then
            if not btn(BUTTON_RIGHT) then
                return DIRECTION_LEFT
            end
        elseif btn(BUTTON_RIGHT) then
            return DIRECTION_RIGHT
        end
    end
end

function toggle(board, q, r)
    toggle_single(board, q, r - 1)
    toggle_single(board, q + 1, r - 1)
    toggle_single(board, q - 1, r)
    toggle_single(board, q, r)
    toggle_single(board, q + 1, r)
    toggle_single(board, q - 1, r + 1)
    toggle_single(board, q, r + 1)
end

function toggle_single(board, q, r)
    if q >= 1 and q <= Q_MAX and r >= 1 and r <= R_MAX then
        board[q][r] = not board[q][r]
    end
end

function game_won()
    for q = 1, Q_MAX do
        for r = 1, R_MAX do
            if STATE.board[q][r] == true then
                return false
            end
        end
    end

    return true
end

function hex_to_point(q, r)
    return
        (q - 1) * HEX_WIDTH + (r - 1) * (HEX_WIDTH // 2) + BOARD_OFFSET_X,
        (r - 1) * HEX_VERTICAL_DISTANCE + BOARD_OFFSET_Y
end


--------------------------------------------------------------------------------
--
-- Game board
--

function mode_won()
    handle_buttons_won()
    draw_board()
    print("Victory!!", 32, 48, 12, nil, 4)
    print("Press B to start again", 48, 80, 12)
end

function handle_buttons_won()
    if btnp(BUTTON_B) then start_game() end
end

function end_game()
    STATE.mode = mode_won
    STATE.selected = nil
end


function clamp(n, min, max)
    if n < min then return min
    elseif max < n then return max
    else return n
    end
end

-- <TILES>
-- 000:0000000000000000000000ff00000fff000fffff00ffffff00ffffff00ffffff
-- 001:0000000000000000f0000000ff000000ffff0000fffff000fffff000fffff000
-- 002:0000000000000000000000cc00000ccc000ccccc00cccccc00cccccc00cccccc
-- 003:0000000000000000c0000000cc000000cccc0000ccccc000ccccc000ccccc000
-- 016:00ffffff00ffffff000fffff0000ffff000000ff000000000000000000000000
-- 017:fffff000fffff000ffff0000fff00000f0000000000000000000000000000000
-- 018:00cccccc00cccccc000ccccc0000cccc000000cc000000000000000000000000
-- 019:ccccc000ccccc000cccc0000ccc00000c0000000000000000000000000000000
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
