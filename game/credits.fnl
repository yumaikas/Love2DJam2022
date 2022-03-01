(import-macros {: each-in : check} :m)
(import-macros { : imp : req : += : -= : *= : unless } :m)
(local v (require :v))
(local f (require :f))
(local assets (require :assets))
(local vectron (require :game.vectron))

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
  (gfx.setFont assets.big-font)
  (gfx.print (if me.won? 
               "GREAT\nDEFENSE!" 
               "FAULT\nBREACH!")
             25 220)
  (let [[_ y ] (v.add me.floor.pos [0 10])
        x 110]
    (gfx.setFont assets.small-font)
    (gfx.setColor [0 1 0])
    (gfx.print "FAULT LINES" x (+ y 30))
    (gfx.print "BY @YUMAIKAS" x (+ y 60))
    (when (f.positive? me.flash)
      (gfx.print "TAP TO PLAY AGAIN" x (+ y 90))))

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

  (if (and (f.negative? me.force-time)
           love.mouse.isJustPressed)
    (let [title (scenes.get :title)]
      (set me.next (title.make))))

  (each [_ c (ipairs me.children)] (c:update dt))

  (each [_ fsh (ipairs me.fish.fish)]
    (when (< fsh.retarget-timer 0)
      (fsh:retarget [10 30] me.fish.dims)))
  )

(fn make [won? surface floor]
  (when (not won?)
    (shake.shake [10 10] 2 (math.rad 30)))
  (assets.battle-song:setLooping false)
  (assets.battle-song:stop)
  (assets.engine:stop)
  (wave:play)
  (let [fish (fish.make-layer 1800 570 30)]
  {
   : surface
   : floor
   : fish
   : won?
   :children (if won? 
               [surface floor fish]
               [surface floor])
   :pos [40 40]
   :flash-period 0.5
   :flash 0.5
   :force-time 3
   :complete false
   :next false
   :wave-delay (f.pick-rand wave-delays)
   : update
   : draw
   }))

{: make}


