(local v (require :v))
(local f (require :f))
(local {: view } (require :fennel))
(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)
(local quit (require :game.quit))
(local start-txt (require :game.title.start-txt))
(local scenes (require :game.scenes))
(local player (require :game.player))

(fn update [me dt]
  (gfx.push)
  (let [[px py] me.player.pos
        (w h) (love.graphics.getDimensions)
        target-x (f.clamp -1200 0 (+ (- px) (/ w 2)))
        ]
    (gfx.translate target-x 0))

  (me.surface:update dt)
  (me.floor:update dt)
  (me.player:update dt)
  (gfx.pop)

  )

(fn draw [me]

  (gfx.push)
  (let [[px py] me.player.pos
        (w h) (love.graphics.getDimensions)
        target-x (f.clamp -1200 0 (+ (- px) (/ w 2)))
        ]
    (gfx.translate target-x 0))

  (me.surface:draw [0 30])
  (me.floor:draw [0 650])
  (me.player:draw)
  (gfx.pop)
  )

(fn make [surface floor] 
  {
   : draw
   : update
   : surface
   : floor
   :player (player.make [60 400])
   :next false
   }
  )

{: make}
