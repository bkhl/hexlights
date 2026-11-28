{:lua-version "lua5.1"
 :libraries {:love2d true}
 :macro-path "src/dev/?.fnlm"
 :lints {;; Gives false positives on xpcall in LuaJIT
         :too-many-arguments false}}
