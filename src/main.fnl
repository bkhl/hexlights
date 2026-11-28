(import-macros {: when-dev} :build)

(local fennel (require "lib.fennel"))

(local context {})

(fn context.switch [mode ...]
  (set context.mode-name mode)
  (set context.mode (require mode))
  (set context.state (context.mode.init ...)))

(fn love.load [_args]
  (love.graphics.setDefaultFilter "nearest" "nearest")
  (context.switch :start))

(fn handle-error [err]
  (if (= context.mode-name :error)
      (.. (tostring err) "\n" (fennel.traceback))
      (do
        (context.switch :error context.mode-name err (fennel.traceback) nil)
        nil)))

(fn handle-callback-result [ok ...]
  (if ok
      (case ... mode_ (context.switch ...))
      (case ... fatal (error fatal 0))))

(fn call-mode-callback [event ...]
  (case (. context.mode event)
    f (handle-callback-result (xpcall f handle-error context.state ...))))

(fn love.update [dt]
  (when context.mode.update
    (call-mode-callback :update dt)))

(fn love.draw []
  (call-mode-callback :draw))

(fn love.keypressed [key code isrepeat]
  (when-dev ((. (require :dev) :keypressed) context key))
  (if (and (love.keyboard.isDown "lctrl" "rctrl" "capslock") (= key "q"))
      (love.event.quit)
      (not isrepeat)
      (call-mode-callback :keypressed key code)))
