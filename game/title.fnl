(local v (require :v))
(local f (require :f))
(local assets (require :assets))
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
(local fish (require :game.fish))

(fn draw [me] 
  (when (> me.flash 0)
    (gfx.setColor [0.4 0.4 1])
    (gfx.setFont assets.big-font)
    (gfx.print "Tag Fish" 40 600))
  (each [_ c (ipairs me.children)] (c:draw))
  )

(fn update [me dt]
  (set me.flash (- me.flash dt))
  (when (< me.flash (- me.flash-period))
    (set me.flash me.flash-period))

  (if love.mouse.isJustPressed
    (let [fish-tag (scenes.get :fish-tag)]
      (set me.next (fish-tag.make me.surface me.floor me.fish))))

  (each [_ c (ipairs me.children)] (c:update dt))

  (each [_ fsh (ipairs me.fish.fish)]
    (when (< fsh.retarget-timer 0)
      (fsh:retarget [10 30] me.fish.dims)))
  )

(fn make []
  (let [surface (surf.make [0 30])
        floor (floor.make [0 500])
        fish (fish.make-layer 1800 570 30) ]
  {
   : surface
   : floor
   : fish
   :children [surface floor fish]
   :pos [40 40]
   :flash-period 0.5
   :flash 0.5
   :complete false
   :next false
   : update
   : draw
   }))

{: make}

