(local v (require :v))
(local f (require :f))
(local vectron (require :game.vectron))
(local submarine (require :game.player.submarine))
(local reticle (require :game.player.reticle))
(local {: view } (require :fennel))
(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)

(fn draw [me]

  (local dist (v.dist me.pos me.target))
  (local (mx my) (love.mouse.getPosition))
  (local (tx ty) (gfx.inverseTransformPoint mx my))
  (if (and (love.mouse.isDown 1)
           (> dist 15))
    (gfx.at [tx ty] #(vectron.draw reticle.shapes))
    (> dist 15)
    (gfx.at me.target
            #(vectron.draw reticle.shapes)))

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
  (when (love.mouse.isDown 1)
    (let [(mxp myp) (love.mouse.getPosition)
          (tx ty) (gfx.inverseTransformPoint mxp myp)]
      (set me.target [tx ty])))
  )

(fn update [me dt]
  (local dist (v.dist me.pos me.target))
  (if 
    (< dist 2)
    (set me.velocity 0)
    (set me.velocity 6))

  (if (< dist 6)
    (do 
      (set me.pos (v.add [0 0] me.target))
      (set me.movement [0 0]))
    (do
      (set me.movement (v.mult 
                         (v.unit (v.sub me.target me.pos)) 
                         me.velocity))
      (set me.pos (v.add me.pos me.movement))))
  (me:set-target dt)
  )

(fn make [pos] 
  {
   :target pos
   :acceleration 10
   :braking 30
   :movement [0 0]
   :velocity 0
   :max-velocity 10
   :old-x-scale 1
   : draw
   : set-target
   : update
   : pos
   }
  )



{ : make }
