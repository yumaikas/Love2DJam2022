(import-macros {: each-in : check} :m)
(import-macros { : imp : req : += : -= : *= : unless } :m)

(req dial :game.dial)

(imp v) (imp f)
(imp moonshine)

(imp assets)
(imp fennel)
(req scenes :game.scenes)
(req title :game.title)
(req shake :game.shake)
(req floor :game.floor)
(req surface :game.floor)

(req dbg :game.debug)


(local gfx love.graphics)

(var MODE {})

(set love.keys {})
(set love.keys.justPressed {})
(set love.keys.down {})

(fn get-window-size [] [(love.graphics.getWidth) (love.graphics.getHeight)])

(fn get-center [] (icollect [_ attr (ipairs (get-window-size))] (/ attr 2)))

(var total-time 0)

(fn love.mousepressed [x y button istouch presses]
  (set love.mouse.isJustPressed true))

(fn love.mousereleased [x y button istouch]
  (set love.mouse.isJustReleased true))

(fn love.mousemoved [x y dx dy] 
  (when (or (not= dx 0) (not= dy 0))
    (set love.mouse.delta [dx dy])))

(fn love.keypressed [_ scancode isrepeat] 
  (tset love.keys.down scancode true)
  (tset love.keys.justPressed scancode true))

(fn love.keyreleased [_ scancode] 
  (tset love.keys.down scancode nil))

(var effect nil)

(fn love.load [] 
  (set effect (moonshine moonshine.effects.glow))
  (set effect.parameters { :glow { :strength 5 :min_luma 0 } })
  (each [_ [name r] 
         (ipairs 
           [[:title :game.title] 
            [:fish-tag :game.fish-tag]
            [:breaking-crust :game.breaking-crust]
            [:first-war :game.first-war]
            [:credits :game.credits]
            ])]
    (scenes.set name (require r)))

  (love.math.setRandomSeed (love.timer.getTime))
  ; Make these configurable?
  (gfx.setLineStyle :rough)
  ; TODO: Switch to none
  (gfx.setLineJoin :miter)
  (gfx.setLineWidth 3)

  (love.mouse.setGrabbed true)
  (let [start (scenes.get :title)]
  (set MODE (start.make true )
       )))

(fn love.draw []
  (gfx.setFont assets.font)

  ; (love.graphics.print (love.timer.getFPS) 10 10)
  (gfx.push)
  (shake.apply gfx)
  (when MODE.draw 
    (effect.draw (fn [] (MODE.draw MODE))))
  (gfx.pop))

(fn love.update [dtprime]
  (local dt (* dtprime (dial.get)))
  (shake.update dt)

  (each [k (pairs love.keys.justPressed)]
    (when (= k :c)
      (love.event.quit))
    (when (= k :t)
      (print "set debug")
      (dbg.set true))
    (match [k (dial.get)] 
      [:p 0] (dial.restore)
      [:p _] (do (dial.save) (dial.set 0)))
    (tset love.keys.justPressed k nil))

  (when MODE.update (MODE:update dt))
  (dbg.set false)

  (set love.mouse.isJustPressed false)
  (set love.mouse.isJustReleased false)
  (set love.mouse.delta nil)

  (when MODE.next
    (set MODE MODE.next)))
