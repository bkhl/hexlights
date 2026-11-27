(import-macros {: when-dev} :build)

(local fennel (require "lib.fennel"))

(local context {})

(fn context.switch [mode ...]
  (set context.mode-name mode)
  (set context.mode (require mode))
  (set context.state (context.mode.init ...)))

(fn love.load [_args]
  (local font (love.graphics.newFont "assets/Kenney Future Square.ttf" 48))
  (love.graphics.setFont font)
  (context.switch :start)
  (love.graphics.setDefaultFilter "nearest" "nearest"))

(fn love.keyreleased [key]
  (when-dev ((. (require :dev) :keyreleased) context key))
  (context.mode.keyreleased context.state key))

(fn safely [f]
  (xpcall f #(context.switch :error context.mode-name $ (fennel.traceback))))

(fn love.draw []
  (safely context.mode.draw))

(fn love.update [dt]
  (when context.mode.update
    (safely #(context.mode.update dt context.switch))))

(fn love.keyreleased [key code isrepeat]
  (if (and (love.keyboard.isDown "lctrl" "rctrl" "capslock") (= key "q"))
      (love.event.quit)
      (not isrepeat)
      (safely #(context.mode.keyreleased key code context.switch))))
