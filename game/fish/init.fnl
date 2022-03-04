(import-macros {: gfx-at : req : imp : -= } :m)
(local v (require :v))
(req {: iter} :f)
(local {: view} (require :fennel))
(local vectron (require :game.vectron))
(req dbg :game.debug)


(req names :game.fish.names)

(local f (require :f))
(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)
(local fish-small (require :game.fish.small1))
(local fish-small-hl (require :game.fish.small1-hl))
(local fish-angel (require :game.fish.angel))
(print (view fish-angel))

(fn draw-fish [me] 
  (gfx-at me.pos
    (if 
      (= 0 (. me.movement 1))
      (gfx.scale me.old-x-scale 1)
      (> 0 (. me.movement 1))
      (do
        (set me.old-x-scale -1)
        (gfx.scale -1 1))
      (do
        (set me.old-x-scale 1)
        (gfx.scale 1 1)))
    (if me.tagged 
      (vectron.draw me.vector-hl.shapes)
      (vectron.draw me.vector.shapes))))

(local move-times [0.5 0.5 1 2 5 8])

(fn retarget-fish [fish [x y] [w h] override-time]
  (let [new-target [(random x w) (random y h)]
        target-time (or override-time (. move-times (random 1 6)))]

    (set fish.target new-target)
    (set fish.retarget-timer target-time)))

(fn update-fish [me dt]
  (set me.retarget-timer  (- me.retarget-timer dt))
  (local dist (v.dist me.pos me.target))
  (if 
    (> dist 10) 
    (set me.velocity 
         (->> me.velocity
              (+ (* dt me.acceleration))
              (f.clamp 0 me.max-velocity)))
    (> dist 2)
    (set me.velocity 0))

  (set me.movement (v.mult 
                     (v.unit (v.sub me.target me.pos)) 
                     (* me.velocity dt)))
  (set me.pos (v.add me.pos me.movement)))

(fn draw [me] 
  (each [fsh (iter me.fish)]
    (fsh:draw))
  (each [angel (iter me.angels)]
    (angel:draw)))

(fn update [me dt] 
  (each [fish (iter me.fish)]
    (fish:update dt))
  (each [angel (iter me.angels)]
    (angel:update dt))
  (when (> (length me.angels) 0)
    (f.filter.i! me.angels (fn [a] (> a.flicker-times 0)))))

(var once true)
(fn update-angel [me dt] 
  (when (dbg.once)
    (print (view me.pos)))
  (when once
    (table.insert love.keys.justPressed :p)
    (set once false))
  (let [dist (v.dist me.pos me.target)]
    (when (> dist 2)
      (set me.pos (v.add me.pos (v.mult [0 -1] (* dt me.velocity)))))
    (when (<= dist 2) (-= me.flicker-timer dt))
    (when (and
            (<= dist 2)
            (f.positive? me.flicker-times)
            (< me.flicker-timer me.flicker-reset))
      (-= me.flicker-times 1)
      (set me.flicker-timer me.flicker-time))))

(fn draw-angel [me]
  (when (f.positive? me.flicker-timer)
    (gfx-at me.pos 
            (vectron.draw fish-angel.shapes))))

(fn kill-fish [me fish h] 
  (set me.fish (f.filter.i me.fish #(not= $ fish)))
  (table.insert me.graveyard fish)
  (table.insert 
    me.angels 
    {
     :pos [(. fish.pos 1) h]
     :draw draw-angel
     :update update-angel
     ; Harcoded Y coord is hardcoded
     :target [(. fish.pos 1) (- h 500)]
     :flicker-times 5
     :velocity 150
     :flicker-timer 0.25
     :flicker-time 0.25
     :flicker-reset -0.25
     })
  )

(local three-times [0 1 2])

(fn strike [me x]
  (let [targeted-fish (f.filter.i me.fish #(< (math.abs (v.x-diff [x 0] $.pos)) 60))]
    (each [_ (iter three-times)]
      (when (> (length targeted-fish) 0)
        (kill-fish me (f.pop-rand targeted-fish (. me.dims 2)) (. me.dims 2))))))

(fn spawn-fish [names w h i] 
  (let [
        [name color] (f.pop-rand names)
        pos [(random 10 w )
             (random 30 h)]]
  {
   : name
   : color
   :update update-fish
   :draw draw-fish
   :vector (fish-small color)
   :vector-hl (fish-small-hl color)
   :acceleration 200
   :max-velocity 300
   :movement [0 0]
   :velocity 0
   :braking 0
   :pos pos
   :target pos
   :retarget retarget-fish
   :retarget-timer 0.0
   }))

(fn make-layer [w h x] 
  {
   :mode :wander
   :dims [w h]
   :fish (let [names* (names)]
               (icollect [i (f.range 1 x)]
                   (spawn-fish names* w h i)))
   :angels []
   :graveyard []
   : kill-fish
   : strike
   : update
   : draw
   })

{: make-layer }
