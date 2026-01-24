x -- title:   Hexlights
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

BUTTON_UP             = 0
BUTTON_DOWN           = 1
BUTTON_LEFT           = 2
BUTTON_RIGHT          = 3

BUTTON_B              = 5

DIRECTION_UP_LEFT     = 0
DIRECTION_UP_RIGHT    = 1
DIRECTION_RIGHT       = 2
DIRECTION_DOWN_RIGHT  = 3
DIRECTION_DOWN_LEFT   = 4
DIRECTION_LEFT        = 5

DIRECTION_TO_VELOCITY = {
    [DIRECTION_UP_LEFT]    = { 0, -1 },
    [DIRECTION_UP_RIGHT]   = { 1, -1 },
    [DIRECTION_RIGHT]      = { 1, 0 },
    [DIRECTION_DOWN_RIGHT] = { 0, 1 },
    [DIRECTION_DOWN_LEFT]  = { -1, 1 },
    [DIRECTION_LEFT]       = { -1, 0 }
}

Q_MAX                 = 11
R_MAX                 = 11

HEX_WIDTH             = 12
HEX_VERTICAL_DISTANCE = 9

HEX_TILES             = { [false] = 0, [true] = 2 }

SELECT_SPRITE         = 256

BOARD_OFFSET_X        = 32
BOARD_OFFSET_Y        = 24


--------------------------------------------------------------------------------
-- Game state

S = {}


--------------------------------------------------------------------------------
-- TIC-80 Callbacks

function _G.BOOT()
    S = { mode = mode_start }
end

function _G.TIC()
    cls(7)
    S.mode()
end

--------------------------------------------------------------------------------
-- Start screen

function mode_start()
    print("Press B to start", 32, 48, 12, nil, 2)

    if btnp(BUTTON_B) then
        S = get_game_start_state()
    end
end

--------------------------------------------------------------------------------
-- Game board

function mode_game()
    handle_buttons_game(S)

    if game_won(S) then S = get_game_end_state(S) end

    draw_board(S)
end

function get_game_start_state()
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

    return {
        mode = mode_game,
        selected = { math.random(1, Q_MAX), math.random(1, R_MAX) },
        directional_button_state = {},
        board = board
    }
end

function draw_board(state)
    for q = 1, Q_MAX do
        for r = 1, R_MAX do
            draw_hex(HEX_TILES[state.board[q][r]], q, r)
        end
    end

    if state.selected then
        draw_hex(SELECT_SPRITE, table.unpack(state.selected))
    end
end

function draw_hex(s, q, r)
    local x, y = hex_to_point(q, r)
    spr(s, (x - 8), (y - 8), 0, 1, 0, 0, 2, 2)
end

function handle_buttons_game(state)
    local q, r = table.unpack(state.selected)

    state.directional_button_state = handle_directional_buttons(
        state.directional_button_state, r
    )

    if state.directional_button_state.move then
        move(state, state.directional_button_state.direction)
    end

    if btnp(BUTTON_B) then
        toggle(state.board, q, r)
    end
end

function handle_directional_buttons(button_state, r)
    local up = btn(BUTTON_UP)
    local down = btn(BUTTON_DOWN)
    local left = btn(BUTTON_LEFT)
    local right = btn(BUTTON_RIGHT)

    if up and down then
        up, down = nil, nil
    end

    if left and right then
        left, right = nil, nil
    end

    if not (up or down or left or right) then
        return {}, nil
    end

    local direction
    -- TODO: Only allow "slipping" on diagonal for one frame.
    if (up and left) or ((up or right) and button_state.direction == DIRECTION_UP_LEFT) then
        direction = DIRECTION_UP_LEFT
    elseif (up and right) or ((up or right) and button_state.direction == DIRECTION_UP_RIGHT) then
        direction = DIRECTION_UP_RIGHT
    elseif (down and left) or ((down or left) and button_state.direction == DIRECTION_DOWN_LEFT) then
        direction = DIRECTION_DOWN_LEFT
    elseif (down and right) or ((down or right) and button_state.direction == DIRECTION_DOWN_RIGHT) then
        direction = DIRECTION_DOWN_RIGHT
    elseif up then
        direction = r % 2 == 0 and DIRECTION_UP_LEFT or DIRECTION_UP_RIGHT
    elseif down then
        direction = r % 2 == 0 and DIRECTION_DOWN_LEFT or DIRECTION_DOWN_RIGHT
    elseif left then
        direction = DIRECTION_LEFT
    elseif right then
        direction = DIRECTION_RIGHT
    end

    local counter = (button_state.counter or 0)
    if counter == 31 then
        counter = 21
    end

    return {
        counter = counter + 1,
        prev = {
            up = up,
            down = down,
            left = left,
            right = right
        },
        direction = direction,
        move = counter == 1 or counter == 21,
    }
end

function move(state, direction)
    local q, r = table.unpack(state.selected)
    local velocity_q, velocity_r = table.unpack(DIRECTION_TO_VELOCITY[direction])
    q, r = q + velocity_q, r + velocity_r
    state.selected = { clamp(q, 1, Q_MAX), clamp(r, 1, R_MAX) }
end

function toggle(board, q, r)
    toggle_aux(board, q, r - 1)
    toggle_aux(board, q + 1, r - 1)
    toggle_aux(board, q - 1, r)
    toggle_aux(board, q, r)
    toggle_aux(board, q + 1, r)
    toggle_aux(board, q - 1, r + 1)
    toggle_aux(board, q, r + 1)
end

function toggle_aux(board, q, r)
    if q >= 1 and q <= Q_MAX and r >= 1 and r <= R_MAX then
        board[q][r] = not board[q][r]
    end
end

function game_won(state)
    for q = 1, Q_MAX do
        for r = 1, R_MAX do
            if state.board[q][r] == true then
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
-- Game end

function mode_game_end()
    handle_button_game_end()
    draw_board(S)
    print("Victory!!", 32, 48, 12, nil, 4)
    print("Press B to start again", 48, 80, 12)
end

function handle_button_game_end()
    if btnp(BUTTON_B) then
        S = get_game_start_state()
    end
end

function get_game_end_state(state)
    return {
        mode = mode_game_end,
        board = state.board
    }
end

--------------------------------------------------------------------------------
-- Utilities

function clamp(n, min, max)
    if n < min then return min end
    if max < n then return max end
    return n
end

--------------------------------------------------------------------------------
-- Resources

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
