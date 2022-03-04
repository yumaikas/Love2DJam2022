(import-macros {: -= : req : imp } :m)
(imp v) (imp f) 
(imp assets)
(req {: view } :fennel)

(req quit :game.quit)
(req scenes :game.scenes)

(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)

(comment
  { :missiles 8 :cost 1000 :delay 15 }
  { :missiles 5 :cost 1000 :delay 15 }
  { :missiles 3 :cost 500 :delay 10 }
  { :missiles 1 :cost 100 :delay 5 }
  )

(local wave-table 
  [
  { :missiles 6 :cost 800 :delay 15 }
  { :missiles 4 :cost 800 :delay 10 }
  { :missiles 3 :cost 500 :delay 8 }
  { :missiles 1 :cost 100 :delay 5 }
   ])
(local start-budget 3500)

(fn spawn-wave [me wave] 
  (let [
        barrage me.barrage
        [w _] me.dims 
        ]
    (for [i 1 wave.missiles]
      (barrage:launch [(random 30 (- w 30)) (random -50 -500)]))
    (-= me.budget wave.cost)
    (set me.wave-delay wave.delay)
    ))

(fn update-wave [me dt] 
  (-= me.wave-delay dt)
  (if (and
          (> me.budget 1000)
          (< me.wave-delay 0))
    (spawn-wave me (f.pick-rand wave-table))

    ; Desperation
    (< me.wave-delay 0)
    (while (> me.budget 0)
      (spawn-wave me (f.find wave-table #(<= $.cost me.budget))))
      )
    )

(fn draw [me]
  (gfx.push)
  (let [[px py] me.player.pos
        (w h) (love.graphics.getDimensions)
        target-x (f.clamp -1350 0 (+ (- px) (/ w 2)))]
    (gfx.translate target-x 0))
  (each [_ c (ipairs me.children)] (c:draw))
  (gfx.pop)

  (let [[_ y ] me.floor.pos
        arc me.arc
        x-end (f.remap arc.charge
                       0 arc.max-charge
                       10 110)
        ]
    (gfx.origin)
    (gfx.setColor [0 1 0])
    (gfx.setFont assets.small-font)
    (gfx.print (.. "ENEMY WAR BUDGET:") 10 (+ y 30))
    (gfx.print (string.format "$%.2f" (f.remap me.budget 0 start-budget 0 10000)) 10 (+ y 60))
    (gfx.print "ARC CHARGE" 10 (+ y 90))
    (gfx.print 
      (string.format "%.2f" me.arc.charge )
                 10 (+ y 120))
  ))

(fn update [me dt] 
  (gfx.push)
  (let [[px py] me.player.pos
        (w h) (love.graphics.getDimensions)
        target-x (f.clamp -1350 0 (+ (- px) (/ w 2))) ]
    (gfx.translate target-x 0))
  (each [_ c (ipairs me.children)] (c:update dt))

  (update-wave me dt)
  (if 
    (and (= me.budget 0)
          (= (length me.barrage.missiles) 0))
    (let [credits (scenes.get :credits)]
      (set me.next (credits.make true me.surface me.floor me.fish)))
    me.floor.breached
    (let [credits (scenes.get :credits)]
      (set me.next (credits.make false me.surface me.floor me.fish)))
    )
  (gfx.pop))

(fn make [dims player surface floor decals barrage arc fish] 
  (assets.battle-song:setLooping true)
  (assets.battle-song:play)
  (let [ [px _] player.pos]
    {
     : update
     : draw
     : dims
     : barrage
     : surface
     : floor
     : decals
     : player
     : arc
     : fish
     ; How long until the next wave is launched
     :wave-delay 0
     :budget start-budget
     :weapons [arc]
     :children [player surface floor decals barrage arc fish]
     :next false
     }))

{: make }
