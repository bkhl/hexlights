;; Keybindings enabled in dev mode.

(fn reload! [context]
  (each [name (pairs (require :fennel-modules))]
    (set (. package.loaded name) nil))
  (let [(ok new) (pcall require context.mode-name)]
    (if ok
        (do
          (set context.mode new)
          (print (.. "Reloaded " context.mode-name))))))

(fn reset! [context]
  (set context.state (context.mode.init))
  (print (.. "Reset state of " context.mode-name)))

(fn keypressed [context key]
  (case key
    :f5 (reload! context)
    :f6 (reset! context)))

{: keypressed}
