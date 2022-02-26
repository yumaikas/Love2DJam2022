(local v (require :v))
(local f (require :f))
(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)

(fn make []
  { 
   :time 0
   :proj-points []
   :points (icollect [i (f.range 0 1800 30)]
              [i 0])

   :update 
   (fn [me dt]
     (set me.time (+ me.time (* 0.5 dt)))
     (set me.proj-points
          (icollect [i [x y] (ipairs me.points)]
                    [x (+ y (- (* (noise i me.time) 20)))]))

     )
   :draw
   (fn [me pos]
     (gfx.push)
     (gfx.translate (unpack pos))
     (gfx.setColor [0.4 0.4 1])
     (gfx.line (v.flatten me.proj-points))
     (gfx.pop))
   })

{
 : make
}

