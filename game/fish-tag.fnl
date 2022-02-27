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
(local decals (require :game.decals))

(fn pick-fish [fish]
  (each [_ fish (ipairs fish)]
    (set fish.tagged false))
  (let [fish (f.pick-rand fish)]
        (set fish.tagged true)
        fish))

(fn do-fish-tag [me]
  (let [{: fish : player} me
        tagged (f.find fish.fish (fn [sh] sh.tagged)) ]
    (when (> 40 (v.dist tagged.pos player.pos))
      (set tagged.tagged false)
      (me.decals:spawn "Tag!" tagged.pos 1 [0 1 1])
      (set me.num-tags (+ 1 me.num-tags))
      (let [new-fish (pick-fish (f.filter.i fish.fish #(< 40 (v.dist $.pos player.pos))))]
        (set new-fish.tagged true))
      )
    (each [_ fsh (ipairs fish.fish)]
      (when (< fsh.retarget-timer 0)
        (fsh:retarget [10 30] fish.dims)))
    (when (>= me.num-tags me.needed-tags)
      (let [lnext (scenes.get :breaking-crust)]
        (set me.next 
             (lnext.make 
               me.fish.dims
               me.player
               me.surface
               me.floor
               me.fish
               me.decals)))
      )
    ))

(fn update [me dt]
  (gfx.push)
  (let [[px py] me.player.pos
        (w h) (love.graphics.getDimensions)
        target-x (f.clamp -1200 0 (+ (- px) (/ w 2))) ]
    (gfx.translate target-x 0))

  (each [_ c (ipairs me.children)] (c:update dt))
  (do-fish-tag me)

  (gfx.pop)
  )

(fn draw [me]
  (gfx.push)
  (let [[px py] me.player.pos
        (w h) (love.graphics.getDimensions)
        target-x (f.clamp -1200 0 (+ (- px) (/ w 2))) ]
    (gfx.translate target-x 0))
  (each [_ c (ipairs me.children)] (c:draw))
  (gfx.pop)
  )

(fn make [surface floor fish] 

  (let [sub (player.make [60 400])
        decal-layer (decals.make)
        ]
    (pick-fish fish.fish)
    {
     : draw
     : update

     : surface
     : floor
     : fish

     :decals decal-layer
     :needed-tags 6
     :num-tags 0
     :player sub

     :children [fish decal-layer sub surface floor]

     :next false
     }
    ))

{: make}
