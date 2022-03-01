(import-macros {: gfx-at : imp : req } :m)
(imp v) (imp f)
(req {: iter} :f)
(req {: engine } :assets) 
(local vectron (require :game.vectron))
(local submarine (require :game.player.submarine))
(local reticle (require :game.player.reticle))
(local {: view } (require :fennel))
(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)

(fn draw [me]

  (local dist (v.dist me.pos me.target))
  (if (and (love.mouse.isDown 1)
           (> dist 15))
    (gfx-at me.target (vectron.draw reticle.shapes))
    (> dist 15)
    (gfx-at me.target (vectron.draw reticle.shapes)))

  (gfx.push)
  (gfx.translate (unpack me.pos))
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
  (vectron.draw submarine.shapes)
  (gfx.pop)
  )

(fn set-target [me dt] 
  (when 
    (and
      love.mouse.isJustPressed
      (love.mouse.isDown 1))
    (let [(mx my) (love.mouse.getPosition)]
      (set me.down-pos [mx my])
      (set me.curr-pos [mx my])
      ))
  (when (love.mouse.isDown 1)
    (let [(mx my) (love.mouse.getPosition)]
      (set me.curr-pos [mx my])))

  (if 
    (and 
        (love.mouse.isDown 1)
        me.curr-pos
        me.down-pos)
    (let [offset (v.clamp-mag 
                   (v.sub me.curr-pos me.down-pos)
                   200)
          [tx ty] (v.add me.pos offset)
          ]
      (set me.target 
           [(f.clamp 0 1800 tx)
           (f.clamp 0 600 ty)]))
    
    (do
      (set me.down-pos false)
      (set me.curr-pos false)
     ))
  (var d [0 0])
  (var any-down? false)
  (let [dirs [
        [:w :up [0 -60]]
        [:s :down [0 60]] 
        [:a :left [-60 0]]
        [:d :right [60 0]]]]
    (each [[k1 k2 adj] (iter dirs)]
      (when (love.keyboard.isDown k1 k2)
        (set any-down? true)
        (set d (v.add d adj)))))

  (let [offset (v.clamp-mag d 60)
        [tx ty] (v.add me.pos offset)
        ]
    (when any-down?
      (set me.target 
           [(f.clamp 0 1800 tx)
            (f.clamp 0 600 ty)])))
  )

(fn update [me dt]
  (local dist (v.dist me.pos me.target))
  (if 
    (< dist 2)
    (set me.velocity 400))

  (if (< dist 6)
    (do 
      (set me.pos (v.add [0 0] me.target))
      (set me.movement [0 0]))
    (do
      (set me.movement (v.mult 
                         (v.unit (v.sub me.target me.pos)) 
                         (* me.velocity dt)))
      (set me.pos (v.add me.pos me.movement))))
  (if (f.positive? (- dist 6))
    (do (engine:play) (engine:setLooping true))
    (engine:setLooping false))

  (me:set-target dt)
  )

(fn make [pos] 
  {
   :down-pos false
   :curr-pos false
   :target pos
   :movement [0 0]
   :velocity 0
   :old-x-scale 1
   : draw
   : set-target
   : update
   : pos
   }
  )



{ : make }
