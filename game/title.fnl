(local v (require :v))
(local f (require :f))
(local vectron (require :game.vectron))

(local {: view } (require :fennel))
(local surf (require :game.surface))
(local floor (require :game.floor))
(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)
(local quit (require :game.quit))
(local start-txt (require :game.title.start-txt))
(local scenes (require :game.scenes))

(fn draw [me] 
  (me.surface:draw [0 30])
  (me.floor:draw [0 650])

  (when (> me.flash 0)
    (gfx.push)
    (vectron.draw [150 680] start-txt.shapes)
    (gfx.pop)))


(fn update [me dt]
  (me.surface:update dt)
  (me.floor:update dt)

  (set me.flash (- me.flash dt))
  (when (< me.flash (- me.flash-period))
    (set me.flash me.flash-period))

  (if love.mouse.isJustPressed
    (let [level1 (scenes.get :level1)]
      (set me.next ( level1.make me.surface me.floor)))))

(fn make []
  (print (view surf))
  {
   :surface (surf.make)
   :floor (floor.make)
   :pos [40 40]
   :flash-period 0.5
   :flash 0.5
   :complete false
   :next false
   : update
   : draw
   })

(let [me {: make}]
  me)
