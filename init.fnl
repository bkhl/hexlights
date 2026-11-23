;; Based on https://codeberg.org/alexjgriffith/min-love2d-fennel/src/commit/3ddc2747e7eb5127203b1198916483fadbdc2e43/wrap.fnl

(local fennel (require :lib.fennel))
(local repl (require :lib.stdio))

(local scale 1)

(local state (require :state))

(local activated-modes {})

(fn set-mode [new-mode-name ...]
  (case (and (. state.mode :leave) (pcall (. state.mode :leave)))
    (false msg) (print state.mode-name "leave error" msg))
  (let [mode (require new-mode-name)]
    (when (and mode.activate (not (. activated-modes mode)))
      (case (pcall mode.activate ...)
        (false msg) (print new-mode-name "activate error" msg)
        _ (tset activated-modes mode true)))
    (case (and mode.enter (pcall mode.enter ...))
      (false msg) (print new-mode-name "enter error" msg))
    (set state.mode mode)
    (set state.mode-name new-mode-name)))

(fn love.load [_args]
  (set-mode "mode.start")
  (love.graphics.setDefaultFilter "nearest" "nearest")
  (when (not= :Web (love.system.getOS)) (repl.start)))

(fn safely [f]
  (xpcall f #(set-mode :error-mode state.mode-name $ (fennel.traceback))))

(fn love.draw []
  (love.graphics.scale scale)
  (safely state.mode.draw))

(fn love.update [dt]
  (when state.mode.update
    (safely #(state.mode.update dt set-mode))))

(fn love.keyreleased [key code isrepeat]
  (if (and (love.keyboard.isDown "lctrl" "rctrl" "capslock") (= key "q"))
      (love.event.quit)
      (not isrepeat)
      (safely #(state.mode.keyreleased key code set-mode))))
