
(local v (require :v))
(local f (require :f))
(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)

(fn make []
  { 
   :time 0
   :proj-points (let [rand (random)]
             (icollect [i (f.range 0 1800 30)]
                       [i (* (noise i rand) 10)]))

   :update 
   (fn [me dt]
     (set me.time (+ me.time (* 0.5 dt))))

   :draw
   (fn [me pos]
     (gfx.push)
     (gfx.translate (unpack pos))
     (gfx.setColor [0.7 0.5 0.3])
     (gfx.line (v.flatten me.proj-points))
     (gfx.pop))
   })

{
 : make
}
