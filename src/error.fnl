;; Based on https://codeberg.org/alexjgriffith/min-love2d-fennel/src/commit/3ddc2747e7eb5127203b1198916483fadbdc2e43/error-mode.fnl

;; This mode has two purposes:
;; * Display the stack trace that caused the error.
;; * Allow the user to decide whether to retry after reloading or quit.
;;
;; Since we can't know which module needs to be reloaded, we rely on the user
;; doing a ,reload foo in the repl.

(local text "Press escape to quit.
Press space to return to the previous mode.")

(local font (love.graphics.setNewFont 16))

(fn draw [state]
  (love.graphics.setFont font)
  (love.graphics.clear 0.34 0.61 0.86)
  (love.graphics.setColor 0.9 0.9 0.9)
  (love.graphics.print text 15 10)
  (love.graphics.print state.message 10 60)
  (love.graphics.print state.traceback 15 125))

(fn keypressed [state key]
  (case key
    :escape (love.event.quit)
    :space state.old-mode))

(fn color-message [message]
  ;; Convert compiler's ANSI escape codes to Löve-friendly codes.
  (case (message:match "(.*)\027%[7m(.*)\027%[0m(.*)")
    (pre selected post) [[1 1 1] pre [1 0.2 0.2] selected [1 1 1] post]
    _ message))

(fn init [old-mode message traceback]
  (print message)
  (print traceback)
  {: old-mode :message (color-message message) : traceback})

{: init : draw : keypressed}
