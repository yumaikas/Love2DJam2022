(import-macros { : req : imp : += : -= : *= : unless : gfx-at } :m)
(imp v) (imp f) 
(req {: iter} :f)
(req vectron :game.vectron)

(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)

(local art 
  [(require :game.cracks.small1)
   (require :game.cracks.medium1)
   (require :game.cracks.large1) ])

(fn make [pos]
  { 
   :time 0
   :cracks [] 
   :proj-points (let [rand (random)]
             (icollect [i (f.range 0 1800 30)]
                       [i (* (noise i rand) 10)]))
   : pos
   :update 
   (fn [me dt]
     (set me.time (+ me.time (* 0.5 dt)))
     (set me.breached
          (or
            (> (length me.cracks) 5)
            (f.any? me.cracks #(> $.mag 3))))
     (each [c (iter me.cracks)]
       (when (> c.mag 3)
         (set c.mag 3))))

   :strike 
   (fn [me x mag]
     ; TODO: Find nearby cracks
     (var numcracks 0)
     (each [_ crack (ipairs me.cracks)] 
       (when (< (f.adiff x crack.x) 40)
         (+= crack.mag 1)
         (+= numcracks 1)))
     (unless (>= numcracks 2)
       (table.insert me.cracks { : x : mag })))

   :draw
   (fn [me]
     (let [[x y] me.pos]
       (gfx.push)
       (gfx.translate x y)
       (gfx.setColor [0.7 0.5 0.3])
       (gfx.line (v.flatten me.proj-points))
       (each [_ crack (ipairs me.cracks)]
         (gfx-at 
           [crack.x 20]
           (vectron.draw (. art crack.mag :shapes))))

       (gfx.pop)))
   })

{
 : make
}
