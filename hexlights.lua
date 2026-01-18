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

BACKGROUND_COLOUR = 6
TEXT_COLOUR = 3

BOARD_OFFSET_X = 32
BOARD_OFFSET_Y = 24


--------------------------------------------------------------------------------
-- Game state

S = {}


--------------------------------------------------------------------------------
-- TIC-80 Callbacks

function _G.BOOT()
    S.mode = mode_start
end

function _G.TIC()
    cls(BACKGROUND_COLOUR)
    S.mode()
end


--------------------------------------------------------------------------------
-- Start screen

function mode_start()
    print("Press B to start", 32, 48, TEXT_COLOUR, nil, 2)

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
    for q = 1, 1 do
        for r = 1, 1 do
            if math.random(0, 1) == 1 then
                toggle(board, q, r)
            end
        end
    end

    S.mode = mode_board
    S.board = board

    S.selected = {math.random(Q_MAX), math.random(R_MAX)}
end

function draw_board()
    for q = 1, Q_MAX do
        for r = 1, R_MAX do
            draw_hex(HEX_TILES[S.board[q][r]], q, r)
        end
    end

    if S.selected then
        draw_hex(SELECT_SPRITE, table.unpack(S.selected))
    end
end

function draw_hex(s, q, r)
    local x, y = hex_to_point(q, r)
    spr(s, (x - 8), (y - 8), BACKGROUND_COLOUR, 1, 0, 0, 2, 2)
end

function handle_buttons_board()
    local q, r = table.unpack(S.selected)

    local direction = get_hexagonal_button_direction(r)

    --[[
        FIXME: Start up/down movement if one of the two of a set of two buttons
        was pressed in previous frame and now both are pressed.
    ]]

    if direction then
        if direction == S.direction
            or (direction == DIRECTION_UP_LEFT and S.direction == DIRECTION_UP_RIGHT)
            or (direction == DIRECTION_UP_RIGHT and S.direction == DIRECTION_UP_LEFT)
            or (direction == DIRECTION_DOWN_RIGHT and S.direction == DIRECTION_DOWN_LEFT)
            or (direction == DIRECTION_DOWN_LEFT and S.direction == DIRECTION_DOWN_RIGHT)
        then
            if S.direction_hold_frames == 0 then
                move_selection(direction)
                S.direction_hold_frames = S.direction_hold_frames + 1
            elseif S.direction_hold_frames == 20 then
                move_selection(direction)
                S.direction_hold_frames = 10
            else
                S.direction_hold_frames = S.direction_hold_frames + 1
            end
        else
            S.direction_hold_frames = 0
        end
        S.direction = direction
    else
        if S.direction and S.direction_holdframes == 0 then
            move_selection(S.direction)
        end
        S.direction = nil
        S.direction_hold_frames = nil
    end

    if btnp(BUTTON_B) then toggle(S.board, q, r) end
end

function move_selection(direction)
    local q, r = table.unpack(S.selected)
    local velocity_q, velocity_r = table.unpack(DIRECTION_TO_VELOCITY[direction])
    q, r = q + velocity_q, r + velocity_r
    S.selected = {clamp(q, 1, Q_MAX), clamp(r, 1, R_MAX)}
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
    elseif btn(BUTTON_LEFT) then
        if not btn(BUTTON_RIGHT) then
            return DIRECTION_LEFT
        end
    elseif btn(BUTTON_RIGHT) then
        return DIRECTION_RIGHT
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
            if S.board[q][r] == true then
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
    print("Victory!!", 32, 48, TEXT_COLOUR, nil, 4)
    print("Press B to start again", 48, 80, TEXT_COLOUR)
end

function handle_buttons_won()
    if btnp(BUTTON_B) then start_game() end
end

function end_game()
    S.mode = mode_won
    S.selected = nil
end


function clamp(n, min, max)
    if n < min then return min
    elseif max < n then return max
    else return n
    end
end

-- <TILES>
-- 000:6666666666666666666666006666600066600000660000006600000066000000
-- 001:6666666666666666066666660066666600006666000006660000066600000666
-- 002:6666666666666666666666116666611166611111661111116611111166111111
-- 003:6666666666666666166666661166666611116666111116661111166611111666
-- 016:6600000066000000666000006666000066666600666666666666666666666666
-- 017:0000066600000666000066660006666606666666666666666666666666666666
-- 018:6611111166111111666111116666111166666611666666666666666666666666
-- 019:1111166611111666111166661116666616666666666666666666666666666666
-- </TILES>

-- <SPRITES>
-- 000:66666666666666f766666f77666f776666f766666f766666676666666f666666
-- 001:66666666f66666667f66666667ff66666667f66666667f666666676666666f66
-- 016:676666666f76666666f76666666f76666666f777666666f76666666666666666
-- 017:6666676666667f666667f666667f6666f7f66666f66666666666666666666666
-- </SPRITES>

-- <PALETTE>
-- 000:000000ffffff772d2685d4dca85fb4559e4a42348bbdcc71a8874ae9b287b66862c5ffffe99df59ddf877e70caffffb0
-- </PALETTE>

