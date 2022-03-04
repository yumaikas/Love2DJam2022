(import-macros {: each-in : check} :m)
(import-macros { : imp : req : += : -= : *= : unless } :m)
(local v (require :v))
(local f (require :f))
(req {: iter} :f)
(local assets (require :assets))
(local vectron (require :game.vectron))
(req decal :game.decals)

(local {: view } (require :fennel))
(local surf (require :game.surface))
(local floor (require :game.floor))
(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)
(local quit (require :game.quit))
(local start-txt (require :game.title.start-txt))
(local scenes (require :game.scenes))
(local fish (require :game.fish))
(req shake :game.shake)
(req {: voice : wave } :assets)

(local wave-delays [2 3 5 5])

(fn draw [me] 
  (gfx.origin)
  (shake.apply gfx)
  (gfx.setColor [0.4 0.4 1])
  (gfx.setFont assets.font)
  (gfx.print (if 
               (and me.won? (f.empty? me.fish.graveyard))
               "GREAT DEFENSE!" 
               me.won?
               "IN MEMORY OF"
               "FAULT BREACH!")
             15 40)
  (let [[_ y ] (v.add me.floor.pos [0 10])
        x 110]
    (gfx.setFont assets.small-font)
    (gfx.setColor [0 1 0])
    (gfx.print "FAULT LINES" x (+ y 30))
    (gfx.print "BY @YUMAIKAS" x (+ y 60))
    (when (f.positive? me.flash)
      (gfx.print (.. "TAP " me.tap-times " TIMES(S)\nTO PLAY AGAIN") x (+ y 90))))

  (each [_ c (ipairs me.children)] (c:draw)))

(fn update [me dt]
  (-= me.flash dt)
  (-= me.force-time)

  (-= me.wave-delay dt)
  (when (f.negative? me.wave-delay)
    (wave:stop)
    (wave:play)
    (set me.wave-delay (f.pick-rand wave-delays)))

  (when (< me.flash (- me.flash-period))
    (set me.flash me.flash-period))

  (if love.mouse.isJustPressed
    (-= me.tap-times 1))
  (when (<= me.tap-times 0)
    (let [title (scenes.get :title)]
      (set me.next (title.make))))

  (each [_ c (ipairs me.children)] (c:update dt))

  (each [_ fsh (ipairs me.fish.fish)]
    (when (< fsh.retarget-timer 0)
      (fsh:retarget [10 30] me.fish.dims)))
  )

(fn make [won? surface floor fish]
  (local decals (decal.make))
  (when (not won?)
    (shake.shake [10 10] 2 (math.rad 30)))
  (assets.battle-song:setLooping false)
  (assets.battle-song:stop)
  (assets.engine:stop)
  (wave:play)
  (if won?
    (each [fsh (iter fish.fish)]
      (set fsh.acceleration 200)
      (set fsh.velocity 0)
      (set fsh.max-velocity 300)
      (fsh:retarget [10 30] [1780 (. floor.pos 2)]))
    (each [fsh (iter fish.fish)]
      (fish:kill-fish fsh (+ (random 10 70) (. floor.pos 2)))))
  (when won?
    (local num-cols (/ (length fish.graveyard) 7))
    (local y-anchor 70)
    (local x-anchor (if (> num-cols 1)
                      25
                      75))
    (var d-x x-anchor)
    (var d-y y-anchor)
    (var col-w 0)
    (var printed-in-col 0)
    (each [a (iter fish.graveyard)]
      (+= printed-in-col 1)
      (set col-w (math.max col-w (decals.font:getWidth a.name)))
      (decals:spawn a.name [d-x d-y] -1 [1 1 1] false)
      (+= d-y 30)
      (when (>= printed-in-col 7)
        (+= d-x (+ col-w 30))
        (set col-w 0)
        (set printed-in-col 0)
        (set d-y y-anchor)
        )
      ))
  {
   : surface
   : floor
   : fish
   : won?
   :children (if won? 
               [surface floor fish decals]
               [surface floor fish decals])
   :pos [40 40]
   :flash-period 0.5
   :flash 0.5
   :force-time 3
   :tap-times 4
   :complete false
   :next false
   :wave-delay (f.pick-rand wave-delays)
   : update
   : draw
   })

{: make}


