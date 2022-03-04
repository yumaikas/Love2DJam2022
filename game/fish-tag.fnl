(import-macros { : += : -= : *= : unless : req : imp } :m)
(imp v) (imp f)

(req {: view} :fennel)

(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)

(local wave-delays [3 5 5 5 8 8])

(req quit :game.quit)
(req scenes :game.scenes)
(req player :game.player)
(req decals :game.decals)
(req {: voice : wave } :assets)

(local already-picked {})

(fn pick-fish [fish]
  (each [_ fish (ipairs fish)]
    (set fish.tagged false))
  (let [fish (f.pick-rand (f.filter.i fish #(not (. already-picked $))))]
        (set fish.tagged true)
        fish))

(fn do-fish-tag [me dt]
  (-= me.wave-delay dt)
  (when (f.negative? me.wave-delay)
    (wave:stop)
    (wave:play)
    (set me.wave-delay (f.pick-rand wave-delays)))

  (let [{: fish : player} me
        tagged (f.find fish.fish (fn [sh] sh.tagged)) ]
    (when (> 40 (v.dist tagged.pos player.pos))
      (set tagged.tagged false)
      (tset already-picked tagged true)
      (me.decals:spawn 
        (string.format (f.pop-rand me.greetings) tagged.name)
        tagged.pos 
        1 
        [0 1 1]
        true)
      (let [new-fish (pick-fish (f.filter.i fish.fish #(< 40 (v.dist $.pos player.pos))))]
        (voice:stop)
        (voice:play)
        (set new-fish.tagged true))
      )
    (each [_ fsh (ipairs fish.fish)]
      (when (< fsh.retarget-timer 0)
        (fsh:retarget [10 30] (v.sub fish.dims [20 0]))))
    (when (f.all? [me.greetings me.decals.elts] f.empty?)
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
        target-x (f.clamp -1350 0 (+ (- px) (/ w 2))) ]
    (gfx.translate target-x 0))

  (each [_ c (ipairs me.children)] (c:update dt))
  (do-fish-tag me dt)

  (gfx.pop)
  )

(fn draw [me]
  (gfx.push)
  (let [[px py] me.player.pos
        (w h) (love.graphics.getDimensions)
        target-x (f.clamp -1350 0 (+ (- px) (/ w 2))) ]
    (gfx.translate target-x 0))
  (each [_ c (ipairs me.children)] (c:draw))
  (gfx.pop)
  )

(fn make [surface floor fish] 

  (let [sub (player.make [60 400])
        decal-layer (decals.make)]
    (pick-fish fish.fish)
    {
     : draw
     : update

     : surface
     : floor
     : fish

     :wave-delay (f.pick-rand wave-delays)
     :decals decal-layer
     :player sub
     :greetings [
                 "Hi,\n%s!"
                 "Morning,\n%s!"
                 "Heyo,\n%s!"
                 "Morning,\n%s!"
                 "Sup\n%s!"
                 "Nice fins\n%s!"
                 ]

     :children [fish decal-layer sub surface floor]

     :next false
     }
    ))

{: make}
