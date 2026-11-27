;; Start screen

(local palette (require :palette))

(fn init []
  (love.graphics.setBackgroundColor palette.cyan)
  {})

(fn draw [_message]
  (love.graphics.printf "Press A to start" 220 140 200 "center"))

(fn keypressed [_key])

{: init : draw : keypressed}
