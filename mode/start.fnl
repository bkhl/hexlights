;; Start screen

(local palette (require :lib.palette))

(fn activate []
  (love.graphics.setBackgroundColor palette.cyan))

(fn draw [_message]
  (love.graphics.printf "Press A to start" 220 140 200 "center"))

{: activate : draw}
