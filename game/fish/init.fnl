(local v (require :v))
(local vectron (require :game.vectron))

(local f (require :f))
(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)
(local fish-small (require :game.fish.small1))

(fn draw-fish [me] 
  (gfx.at me.pos
    (fn [] 
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
        (vectron.draw-switch-color 
          me.vector.shapes
          [1 0.16 1]
          [0.3 0.3 1])
        (vectron.draw me.vector.shapes))))
  )

(local move-times [0.5 0.5 1 2 5 8])

(fn retarget-fish [fish [x y] [w h] override-time]
  (let [new-target [(random x (- w 10))
             (random y (- h 100))]
        target-time (or override-time (. move-times (random 1 6)))]
    (set fish.target new-target)
    (set fish.retarget-timer target-time)))

(fn update-fish [me dt]
  (set me.retarget-timer (- me.retarget-timer dt))
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
                     me.velocity))
  (set me.pos (v.add me.pos me.movement))
  )

(fn draw [me] 
  (each [_ fish (ipairs me.fish)]
    (fish:draw)))

(fn update [me dt] 
  (each [_ fish (ipairs me.fish)]
    (fish:update dt)))


(fn spawn-fish [w h i] 
  (let [pos [(random 10 w )
             (random 30 h)]]
  {
   :update update-fish
   :draw draw-fish
   :vector fish-small
   :acceleration 5
   :max-velocity 3
   :movement [0 0]
   :velocity 0
   :braking 0
   :pos pos
   :target pos
   :retarget retarget-fish
   :retarget-timer 0.0
   :alive true
   }))

(fn make-layer [w h x] 
  {
   :mode :wander
   :dims [w h]
   :fish (icollect [i (f.range 1 x)]
                   (spawn-fish w h i))
   : update
   : draw
   })

{: make-layer }
