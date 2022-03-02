(import-macros {: -= : += : req : imp : gfx-at } :m)
(req {: iter} :f)
(req {: view} :fennel)
(imp v) (imp c) (imp f)
(req {: zap : ping } :assets)

(local random love.math.random)
(local gfx love.graphics)

(fn draw-spark-line [a b] 
  (let [
        [x1 y1] a
        [xend yend] b
        line (v.sub b a)
        mag (v.mag line)
        u (v.unit line)
        up (v.rot<90 u)
        down (v.rot>90 u)
        choices [up down]
        ratio (/ mag 7)
        pts (icollect [i (f.range 2 6) :into [[x1 y1]]]
                   (v.add  
                     (v.mult (f.pick-rand choices) 
                             (* 10 (random 1 2)))
                     (v.add a (v.mult u (* ratio i)))))]
    (gfx.setColor [1 1 1])
    (table.insert pts [xend yend])
    ; (print (view (v.flatten pts)))
    (gfx.line (v.flatten pts))
    ))

(local dirs (let [ [lstart lstop] [15 40]]
              [ [0 lstart 0 lstop] ; up
               [0 (- lstart) 0 (- lstop)] ; down
               [lstart 0  lstop 0] ; right
               [(- lstart) 0 (- lstop) 0] ; left
               ]))

(fn draw-lockon [[x y]]
  (gfx.push)
  (gfx.setColor [1 1 1])
  (gfx.translate x y) 
  (each [[sx sy ex ey] (f.iter dirs)]
    (gfx.line sx sy ex ey))
  (gfx.pop))

(fn draw [me]
  ; Arc is drawn based on simplex noise offsets from a straight line
  ; Arc is shown for .25 seconds
  (each [{: from : to} (iter me.lines)] 
    (draw-spark-line from to))
  (each [t (iter me.reticles)]
    (draw-lockon t.pos))
  (gfx-at (v.add me.player.pos [-50 30])
    (let [ x-end (f.remap me.charge 0 me.max-charge 10 85)]
    (gfx.setColor 0.6 0.6 0.6)
    (gfx.rectangle :line 0 0 90 15) 
    (if (> me.charge 1)
      (gfx.setColor 0.4 0.4 1)
      (gfx.setColor 1 0 0))
    (gfx.line 5 5 x-end 5)))
  )

(fn add-line [me from to t]
  (zap:stop)
  (zap:play)
  (table.insert me.lines {: from : to : t}))

(fn update [me dt]
  ; (print (view me))
  (set me.player-delta (v.sub me.player.pos me.old-player-pos))
  (each [l (iter me.lines)]
    (-=  l.t dt))
  (f.filter.i! me.lines #(> $.t 0))

  (if (<= me.charge 1)
    (set me.targets [])
    ; Only keep targets in range
    (do
      ; Only go for targets in range
      (f.filter.i! me.targets #(<= (v.dist $.pos me.player.pos) me.range))
      ; Sort the targets by distance
      (table.sort me.targets (fn [a b]
                               (<
                                (v.dist a.pos me.player.pos)
                                (v.dist b.pos me.player.pos))))
      ; As many as we have charge for, closest first
      (set me.targets
           (f.slice me.targets 1 (math.floor me.charge)))))
  (set me.reticles 
       (icollect [{:pos [x y]} (iter me.targets)]
                 {:pos [x y]}))

  (match [me.player-delta (length me.targets) (> me.charge 0)]
     [[0 0] 0 _] (set me.charge (math.max 0 (- me.charge (/ dt 2))))
     [[0 0] t true] 
     (do 
       (set me.charge (f.clamp 0 me.max-charge (- me.charge t)))

       (each [t (iter me.targets)]
         (let [{:pos [tx ty]} t]
           (me:add-line me.player.pos [tx ty] 0.5)
           (t:harm :spark 1))))
     _ (do 
         (local old-charge me.charge)
         (set me.charge 
            (math.min (+ me.charge dt) me.max-charge)) 
         (when
           (and (> 1 old-charge)
                (<= 1 me.charge))
           (ping:stop)
           (ping:play)))
     )

  (set me.targets [])
  (set me.old-player-pos (v.add [0 0] me.player.pos)))

(fn give-targets [me targets] 
  (icollect [t (iter targets) :into me.targets] t))

(fn make [player charge-pos] 
  {
   : update
   : draw 
   : give-targets
   : add-line
   :lines []
   :reticles []
   :targets []
   :range 200
   :charge 0
   :max-charge 2
   :drain-speed 0.3
   : player
   :old-player-pos player.pos
   }
  )

{: make }
