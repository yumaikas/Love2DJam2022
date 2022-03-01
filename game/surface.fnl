(local v (require :v))
(local f (require :f))
(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)

(fn make [pos]
  (local points (icollect [i (f.range 0 1800 30)]
              [i 0]))
  { 
   :time 0
   :proj-points points
   :impacts [ ]
   : pos
   :points points

   :impact 
   (fn [me x magnitude] 
     (table.insert me.impacts {: x : magnitude}))

   :update 
   (fn [me dt]
     (set me.time (+ me.time (* 0.5 dt)))
     (set me.proj-points
          (icollect [i [x y] (ipairs me.points)]
                    (let [mag (accumulate 
                                [sum 20
                                 _ {:x mx : magnitude} (ipairs me.impacts)]
                                (if (< (math.abs (- x mx)) 60)
                                  (+ sum magnitude)
                                  sum))]
                      [x (+ y (- (* (noise i me.time) mag)))]
                    )))
     (each [_ i (ipairs me.impacts)]
       (set i.magnitude (- i.magnitude (* dt 20))))
     (f.filter.i! me.impacts #(< 0 $.magnitude))
     )
   :draw
   (fn [me]
     (gfx.push)
     (gfx.translate (unpack me.pos))
     (gfx.setColor [0.4 0.4 1])
     (gfx.line (v.flatten me.proj-points))
     (gfx.pop))
   })

{
 : make
}

