-- title:   Hexlights
-- author:  Bjoern Lindstroem <bkhl@elektrubadur.se>
-- desc:    Hexagonal lights out
-- site:    https://github.com/bkhl/hexlights
-- license: MIT License
-- version: 0.1
-- script:  lua
-- input:   gamepad

local M                      = {}

--------------------------------------------------------------------------------
--
-- Constants
--

local BUTTON_UP              = 0
local BUTTON_DOWN            = 1
local BUTTON_LEFT            = 2
local BUTTON_RIGHT           = 3

local BUTTON_B               = 5

local DIRECTION_UP_LEFT      = 0
local DIRECTION_UP_RIGHT     = 1
local DIRECTION_RIGHT        = 2
local DIRECTION_DOWN_RIGHT   = 3
local DIRECTION_DOWN_LEFT    = 4
local DIRECTION_LEFT         = 5

local DIRECTION_TO_VELOCITY  = {
    [DIRECTION_UP_LEFT]    = { 0, -1 },
    [DIRECTION_UP_RIGHT]   = { 1, -1 },
    [DIRECTION_RIGHT]      = { 1, 0 },
    [DIRECTION_DOWN_RIGHT] = { 0, 1 },
    [DIRECTION_DOWN_LEFT]  = { -1, 1 },
    [DIRECTION_LEFT]       = { -1, 0 }
}

local BUTTON_REPEAT_DELAY    = 20
local BUTTON_REPEAT_INTERVAL = 10
local INPUT_BUFFER_SIZE      = 4

local Q_MAX                  = 11
local R_MAX                  = 11

local HEX_WIDTH              = 12
local HEX_VERTICAL_DISTANCE  = 9

local HEX_TILES              = { [false] = 0, [true] = 2 }

local SELECT_SPRITE          = 256

local BOARD_OFFSET_X         = 32
local BOARD_OFFSET_Y         = 24


--------------------------------------------------------------------------------
-- TIC-80 Callbacks

function _G.BOOT()
    _G.state = { mode = M.mode_start }
end

function _G.TIC()
    cls(7)
    _G.state.mode()
end

--------------------------------------------------------------------------------
-- Start screen

function M.mode_start()
    print("Press B to start", 32, 48, 12, nil, 2)

    if btnp(BUTTON_B) then
        _G.state = M.get_game_start_state()
    end
end

--------------------------------------------------------------------------------
-- Game board

function M.mode_game()
    M.handle_buttons_game(_G.state)

    if M.game_won(_G.state) then _G.state = M.get_game_end_state(_G.state) end

    M.draw_board(_G.state)
end

function M.get_game_start_state()
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
                M.toggle(board, q, r)
            end
        end
    end

    return {
        mode = M.mode_game,
        selected = { math.random(1, Q_MAX), math.random(1, R_MAX) },
        direction_input_buffer = {},
        board = board
    }
end

function M.draw_board(state)
    for q = 1, Q_MAX do
        for r = 1, R_MAX do
            M.draw_hex(HEX_TILES[state.board[q][r]], q, r)
        end
    end

    if state.selected then
        M.draw_hex(SELECT_SPRITE, table.unpack(state.selected))
    end
end

function M.draw_hex(s, q, r)
    local x, y = M.hex_to_point(q, r)
    spr(s, (x - 8), (y - 8), 0, 1, 0, 0, 2, 2)
end

function M.handle_buttons_game(state)
    local q, r = table.unpack(state.selected)

    local move_direction
    state.direction_input_buffer, move_direction = M.handle_directional_buttons(
        state.direction_input_buffer,
        r % 2 == 0
    )

    if move_direction then
        M.move(state, move_direction)
    end

    if btnp(BUTTON_B) then
        M.toggle(state.board, q, r)
    end
end

function M.handle_directional_buttons(input_buffer, even_row)
    input_buffer.i = (input_buffer.i and input_buffer.i ~= INPUT_BUFFER_SIZE)
        and (input_buffer.i + 1)
        or 1

    input_buffer[input_buffer.i] = {
        up = btn(BUTTON_UP),
        down = btn(BUTTON_DOWN),
        left = btn(BUTTON_LEFT),
        right = btn(BUTTON_RIGHT),
    }

    input_buffer.filled = input_buffer.filled or (input_buffer.i == INPUT_BUFFER_SIZE)

    if not input_buffer.filled then
        return input_buffer, nil
    end

    local up, down, left, right
    for j = 1, INPUT_BUFFER_SIZE do
        if input_buffer[j].up then up = true end
        if input_buffer[j].down then down = true end
        if input_buffer[j].left then left = true end
        if input_buffer[j].right then right = true end
    end

    if up and down then
        up = false
        down = false
    end

    if left and right then
        left = false
        right = false
    end

    local direction = M.get_direction(up, down, left, right, even_row)

    if not direction then
        return {}, nil
    end

    local move_direction
    if input_buffer.counter then
        if input_buffer.counter == BUTTON_REPEAT_DELAY then
            move_direction = direction
            input_buffer.counter = BUTTON_REPEAT_DELAY - BUTTON_REPEAT_INTERVAL
        end
    else
        move_direction = direction
        input_buffer.counter = 0
    end

    input_buffer.counter = input_buffer.counter + 1

    return input_buffer, move_direction
end

function M.get_direction(up, down, left, right, even_row)
    if (up and left) then
        return DIRECTION_UP_LEFT
    elseif (up and right) then
        return DIRECTION_UP_RIGHT
    elseif (down and left) then
        return DIRECTION_DOWN_LEFT
    elseif (down and right) then
        return DIRECTION_DOWN_RIGHT
    elseif up then
        return even_row and DIRECTION_UP_LEFT or DIRECTION_UP_RIGHT
    elseif down then
        return even_row and DIRECTION_DOWN_LEFT or DIRECTION_DOWN_RIGHT
    elseif left then
        return DIRECTION_LEFT
    elseif right then
        return DIRECTION_RIGHT
    end
end

function M.move(state, direction)
    local q, r = table.unpack(state.selected)
    local velocity_q, velocity_r = table.unpack(DIRECTION_TO_VELOCITY[direction])
    q, r = q + velocity_q, r + velocity_r
    state.selected = { M.clamp(q, 1, Q_MAX), M.clamp(r, 1, R_MAX) }
end

function M.toggle(board, q, r)
    M.toggle_aux(board, q, r - 1)
    M.toggle_aux(board, q + 1, r - 1)
    M.toggle_aux(board, q - 1, r)
    M.toggle_aux(board, q, r)
    M.toggle_aux(board, q + 1, r)
    M.toggle_aux(board, q - 1, r + 1)
    M.toggle_aux(board, q, r + 1)
end

function M.toggle_aux(board, q, r)
    if q >= 1 and q <= Q_MAX and r >= 1 and r <= R_MAX then
        board[q][r] = not board[q][r]
    end
end

function M.game_won(state)
    for q = 1, Q_MAX do
        for r = 1, R_MAX do
            if state.board[q][r] == true then
                return false
            end
        end
    end

    return true
end

function M.hex_to_point(q, r)
    return
        (q - 1) * HEX_WIDTH + (r - 1) * (HEX_WIDTH // 2) + BOARD_OFFSET_X,
        (r - 1) * HEX_VERTICAL_DISTANCE + BOARD_OFFSET_Y
end

--------------------------------------------------------------------------------
-- Game end

function M.mode_game_end()
    M.handle_button_game_end()
    M.draw_board(_G.state)
    print("Victory!!", 32, 48, 12, nil, 4)
    print("Press B to start again", 48, 80, 12)
end

function M.handle_button_game_end()
    if btnp(BUTTON_B) then
        _G.state = M.get_game_start_state()
    end
end

function M.get_game_end_state(state)
    return {
        mode = M.mode_game_end,
        board = state.board
    }
end

--------------------------------------------------------------------------------
-- Utilities

function M.clamp(n, min, max)
    if n < min then return min end
    if max < n then return max end
    return n
end

--------------------------------------------------------------------------------
-- Return module table for tests

return M

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
