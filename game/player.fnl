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

  (gfx.push)
  (gfx.translate (unpack me.target))
  (vectron.draw [0 0] reticle.shapes)
  (gfx.pop)


  (gfx.push)
  (gfx.translate (unpack me.pos))
  (if (> 0 (. me.movement 1))
    (gfx.scale -1 1)
    (gfx.scale 1 1))
  ; Guessing at the right factor
  (vectron.draw [0 0] submarine.shapes)
  (gfx.pop)
  )

(fn update [me dt]
  (when love.mouse.isJustPressed
      (set me.velocity (f.clamp 0 me.max-velocity (- me.velocity 2))))
  (when (love.mouse.isDown 1)
    (let [(mxp myp) (love.mouse.getPosition)
          (tx ty) (gfx.inverseTransformPoint mxp myp)]
      (set me.target [tx ty])))

  (local dist (v.dist me.pos me.target))
  (if 
    (> dist 50) 
    (set me.velocity 
         (->> me.velocity
              (+ (* dt me.acceleration))
              (f.clamp 0 me.max-velocity)))
    (> dist 10)
    (set me.velocity
         (->> (- me.velocity (* dt me.braking))
              (f.clamp 0 me.max-velocity)))
    (< dist 5)
    (set me.velocity 0))

  (set me.movement (v.mult 
                     (v.unit (v.sub me.target me.pos)) 
                     me.velocity))
  (set me.pos (v.add me.pos me.movement)))


(fn make [pos] 
  {
   :target pos
   :acceleration 10
   :braking 30
   :movement [0 0]
   :velocity 0
   :max-velocity 10
   : draw
   : update
   : pos
   }
  )



{ : make }
