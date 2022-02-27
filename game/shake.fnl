(local random love.math.random)
(import-macros {: -= } :m)

(local me {})

(fn me.update [dt]
  (let [[mx my] me.mag]
    (set me.offset 
         [(random (- mx) mx)
          (random (- my) my)])
    (set me.rot (math.rad (random (- me.rmag) me.rmag)))
    (-= me.time dt)
  ))

(fn me.shake [mag time rot]
  (let [[mx my] mag]
  (set me.mag [mx my])
  (set me.rmag rot)
  (set me.time time)))

(fn me.apply [gfx]
  (when (> me.time 0)
    (let [[ox oy] me.offset]
      (gfx.translate ox oy)
      (gfx.rotate me.rot)
      )))


(set me.rot 0)
(set me.mag [0 0])
(set me.rmag 0)
(set me.time 0)
(set me.offset [0 0])

me
