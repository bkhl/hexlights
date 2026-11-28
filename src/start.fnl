;; Start screen

(local palette (require :palette))

(local font (love.graphics.newFont "assets/Kenney Future Square.ttf" 48))

(fn init []
  (love.graphics.setFont font)
  (love.graphics.setBackgroundColor palette.cyan)
  {})

(fn draw []
  (love.graphics.printf "Press A to start" 220 140 200 "center"))

{: init : draw}
