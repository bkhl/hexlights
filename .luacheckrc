-- -*- mode: lua -*-

return {
    std = {
        globals = {
            "_G",
            "require",

            -- Lua stdlib
            "math",
            "table",

            -- Busted
            "describe",
            "it",
            "assert",

            -- Drawing
            "circ",
            "circb",
            "elli",
            "ellib",
            "clip",
            "cls",
            "font",
            "line",
            "map",
            "pix",
            "print",
            "rect",
            "rectb",
            "spr",
            "tri",
            "trib",
            "textri",
            "ttri",

            -- Input
            "btn",
            "btnp",
            "key",
            "keyp",
            "mouse",

            -- Sound
            "music",
            "sfx",

            -- Memory
            "memcpy",
            "memset",
            "pmem",
            "peek",
            "peek1",
            "peek2",
            "peek4",
            "poke",
            "poke1",
            "poke2",
            "poke4",
            "sync",
            "vbank",

            -- Utilities
            "fget",
            "fset",
            "mget",
            "mset",

            -- System
            "exit",
            "reset",
            "time",
            "tstamp",
            "trace"
        }
    }
}
