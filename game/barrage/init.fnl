(import-macros { : imp : req : += : -= : *= : unless } :m)

(imp v) (imp f)
(req {: view} :fennel)
(req vectron :game.vectron)
(req shake :game.shake)

(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)

(local art 
  {
   :missile (require :game.barrage.quake-missile)
   :warning-up (require :game.warnings.up)
   :warning-right (require :game.warnings.right)
   :warning-left (require :game.warnings.left)
   })

(fn draw-missile [me surface player]
  (if 
    ; Above in the air
    (< (. me.pos 2) 0)
    (let [
          y (. surface.pos 2)
          missile-x (. me.pos 1)
          (w _) (love.graphics.getDimensions)
          px (. player.pos 1)
          min-x (- px (/ w 2))
          max-x (+ px (/ w 2))
          x (f.clamp min-x max-x missile-x)]
      (gfx.at [x y]
        #(vectron.draw art.warning-up.shapes)))

    ; Sinking to floor
    (>= (. me.pos 2) 0)
    (let [[x y] me.pos
          missile-x (. me.pos 1)
          (w _) (love.graphics.getDimensions)
          px (. player.pos 1)
          min-x (- px (/ w 2))
          max-x (+ px (/ w 2)) ] 
      (if 
        (< missile-x min-x)
        (gfx.at [(+ min-x 20) y] #(vectron.draw art.warning-left.shapes))
        (> missile-x max-x)
        (gfx.at [(- max-x 20) y] #(vectron.draw art.warning-right.shapes))
        (gfx.at [x y] #(vectron.draw art.missile.shapes))
      )
      )))

(fn update-missile [me surface floor dt] 
  (print (view (. me.pos 2)))
  (if 
    ; Above in the air
    (< (. me.pos 2) 0)
    (tset me.pos 2 (math.min (+ (. me.pos 2) (* 50 dt)) 0))
    ; Hit the water
    (= (. me.pos 2) 0)
    (let [[x _] me.pos]
      (shake.shake [2 2] 0.5 1)
      (surface:impact x 100)
      (tset me.pos 2 0.1))

    ; Hit floor
    (> (. me.pos 2) (. floor.pos 2))
    (let [[x _] me.pos]
      (set me.alive false)
      (shake.shake [4 4] 1 2)
      (floor:strike x 1))
    ; Sinking to floor
    (> (. me.pos 2) 0)
    (tset me.pos 2 (+ (. me.pos 2) (* 60 dt)))
  ))

(fn update [me dt]
  (each [_ m (ipairs me.missiles)]
    (m:update me.surface me.floor dt))
  (f.filter.i! me.missiles #(. $ :alive)))

(fn draw [me] 
  (each [_ m (ipairs me.missiles)]
    ; To be able to clamp warnings 
    (m:draw me.surface me.player)))

(fn launch [me pos] 
  (table.insert
    me.missiles 
    {:update update-missile
     :draw draw-missile
     : pos :alive true }))

(fn make [player surface floor] 

  {
   : launch
   :missiles []
   : update
   : draw
   : player
   : surface
   : floor
   }
  )

{: make }
