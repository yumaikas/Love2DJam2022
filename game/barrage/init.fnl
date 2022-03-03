(import-macros { : imp : req : += : -= : *= : unless : gfx-at } :m)

(imp v) (imp f)
(req {: iter } :f)
(req {: view} :fennel)
(req vectron :game.vectron)
(req shake :game.shake)
(req { : water-hits : ground-hit :missile-ping ping } :assets)

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
      (gfx-at [x y]
        (vectron.draw art.warning-up.shapes)))

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
        (gfx-at [(+ min-x 20) y] (vectron.draw art.warning-left.shapes))
        (> missile-x max-x)
        (gfx-at [(- max-x 20) y] (vectron.draw art.warning-right.shapes))
        (gfx-at [x y] (vectron.draw art.missile.shapes))
      )
      )))

(fn update-missile [me surface floor fish dt] 
  (if 
    ; Above in the air
    (< (. me.pos 2) 0)
    (tset me.pos 2 (math.min (+ (. me.pos 2) (* 50 dt)) 0))
    ; Hit the water
    (= (. me.pos 2) 0)
    (let [[x _] me.pos
          snd (f.pick-rand water-hits) ]
      (snd:stop)
      (snd:play)
      (shake.shake [2 2] 0.5 1)
      (surface:impact x 100)
      (tset me.pos 2 0.1))

    ; Hit floor
    (> (. me.pos 2) (. floor.pos 2))
    (let [[x _] me.pos]
      (ground-hit:stop)
      (ground-hit:play)
      (set me.alive false)
      (shake.shake [4 4] 1 2)
      (floor:strike x 1)
      (fish:strike x)
      )
    ; Sinking to floor
    (> (. me.pos 2) 0)
    (tset me.pos 2 (+ (. me.pos 2) (* 60 dt)))
  ))

(fn harm-missile [me dam-type amt]
  (set me.alive false))

(fn update [me dt]
  (each [m (iter me.missiles)]
    (m:update me.surface me.floor me.fish dt))
  (f.filter.i! me.missiles #(. $ :alive))
  (each [w (iter me.weapons)]
    (w:give-targets 
      (f.filter.i me.missiles #(f.positive? (. $.pos 2))))))

(fn draw [me] 
  (each [m (iter me.missiles)]
    ; To be able to clamp warnings 
    (m:draw me.surface me.player)))

(fn launch [me pos] 
  (ping:stop)
  (ping:play)
  (table.insert
    me.missiles 
    {:update update-missile
     :draw draw-missile
     :harm harm-missile
     : pos :alive true }))

(fn make [player surface floor weapons fish] 

  {
   : launch
   :missiles []
   : fish
   : weapons
   : update
   : draw
   : player
   : surface
   : floor
   : fish
   }
  )

{: make }
