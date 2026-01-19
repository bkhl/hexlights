-- -*- mode: lua -*-

allow_defined_top = true
codes = true

ignore = {
    "113", -- Accessing an undefined global variable.
    "131", -- Unused implicitly defined global variable.
    "143"  -- Accessing an undefined field of a global variable.
}
