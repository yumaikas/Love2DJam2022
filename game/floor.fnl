(local v (require :v))
(local f (require :f))
(import-macros { : += : -= : *= : unless } :m)

(local vectron (require :game.vectron))
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
     (set me.time (+ me.time (* 0.5 dt))))

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
         (gfx.at 
           [crack.x 20]
           #(vectron.draw (. art crack.mag :shapes))))

       (gfx.pop)))
   })

{
 : make
}
