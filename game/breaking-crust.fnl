(import-macros {: -= : req : imp } :m)
(imp v) (imp f) (imp assets)

(req {: view } :fennel)

(req quit :game.quit)
(req start-txt :game.title.start-txt)
(req scenes :game.scenes)
(req player :game.player)
(req barrage :game.barrage)
(req decals  :game.decals)
(req arc-weapon :game.arc-weapon)
(req interlude :game.interlude)
(req warning-vec :game.warnings.up)
(req reticle :game.player.reticle)

(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)

(fn start-fish-flee [fish] 
  (let [
        [w h] fish.dims
        inner-corner [-50 (+ h 300)]
        outer-corner (v.add fish.dims [50 600])
        ]
  (each [_ fish (ipairs fish.fish)]
    (set fish.velocity 600)
    (set fish.max-velocity 600)
    (fish:retarget inner-corner outer-corner 10))))

(fn draw [me dt]
  (gfx.push)
  (let [[px py] me.player.pos
        (w h) (love.graphics.getDimensions)
        target-x (f.clamp -1350 0 (+ (- px) (/ w 2))) ]
    (gfx.translate target-x 0))
  (each [_ c (ipairs me.children)] (c:draw))

  (gfx.pop)
  (let [[_ y ] me.floor.pos
        arc me.arc
        x-end (f.remap arc.charge
                       0 arc.max-charge
                       10 110) ]
    (gfx.origin)
    (gfx.setFont assets.small-font)
    (gfx.setColor [0 1 0])
    (gfx.print "MOVE TO CHARGE" 10 (+ y 30))
    (gfx.print "STOP TO FIRE" 10 (+ y 60))
    (gfx.print "ARC CHARGE" 10 (+ y 90))
    (gfx.print 
      (string.format "%.2f" me.arc.charge )
                 10 (+ y 120))
    )
  )

(fn update [me dt] 
  (gfx.push)
  (let [[px py] me.player.pos
        (w h) (love.graphics.getDimensions)
        target-x (f.clamp -1350 0 (+ (- px) (/ w 2))) ]
    (gfx.translate target-x 0))
  (each [_ c (ipairs me.children)] (c:update dt))
  (when (>= 0 (length me.barr.missiles))
    (let [war (scenes.get :first-war)]
      (set me.next (war.make 
                     me.dims
                     me.player
                     me.surface
                     me.floor
                     me.decals
                     me.barr
                     me.arc
                     me.fish
                     ))))
  (gfx.pop)
  )

(fn make [dims player surface floor fish decals] 
  (assets.pre-intro:play)
  (let [arc (arc-weapon.make player)
        barr (barrage.make player surface floor [arc] fish)
        [px _] player.pos]
    (start-fish-flee fish)
    (barr:launch [px -100])
    (let [me {
              : update
              : draw
              : dims
              : barr
              : surface
              : floor
              : fish
              : decals
              : player
              : arc
              :weapons [arc]
              :children [player surface floor fish decals barr arc]
              :next false
              }]
     (interlude.make 
       me
       [ 
        { :font assets.small-font :color [1 1 0]
           :pos [30 70]
           :text "\"TREMOR MISSILES?!\"" }
        { :font assets.small-font :color [1 1 0]
           :pos [30 100]
           :text "\"DO THEY WANT A QUAKE?!\"" }

        { :font assets.small-font :color [0 1 0]
           :pos [40 160]
           :text "MOVE TO CHARGE ARC CANNON" }
        { :font assets.small-font :color [0 1 0]
           :pos [40 190]
           :text "STOP TO RELEASE CHARGE" }
        { :font assets.small-font :color [0 1 0]
           :pos [40 220]
           :text "AND DESTROY MISSILES" }
        ]
       [ {
          :vectr warning-vec
          :pos [225 25]
          }
        ]

      ))))

{: make }
